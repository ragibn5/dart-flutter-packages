package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [VolumePathResolver] finds the filesystem root a [StorageVolume] is mounted at.
 *
 * On API 30 and above it asks the volume itself; below that the primary volume
 * falls back to the external storage directory and a secondary one is matched
 * against the app's external files dirs. Both branches are covered by pinning the
 * SDK level, and the paths are absolute so the result never depends on the
 * machine running the tests.
 */
internal class VolumePathResolverTest {
    private val context: Context = Mockito.mock(Context::class.java)
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)

    /** The volumes [storageManager] vouches for, by their roots. */
    private val mounted = mutableMapOf<String, StorageVolume>()

    /**
     * `getExternalFilesDirs` returns the per-app dirs, which sit four segments
     * below the volume root.
     */
    private fun externalDirs(vararg dirs: String) {
        Mockito.`when`(context.getExternalFilesDirs(Mockito.any()))
            .thenReturn(dirs.map(::File).toTypedArray())
    }

    /**
     * A [StorageVolume] reporting [uuid], mounted at [root].
     *
     * [root] is what `StorageManager` answers for a path under it, which is how
     * the pre-API 30 branch finds a volume in the first place. It is deliberately
     * separate from [volumeOn]'s `directory`: below API 30 the volume itself is
     * never asked where it is mounted.
     */
    private fun volumeOn(
        root: String,
        isPrimary: Boolean = false,
        uuid: String? = "1234-5678",
        directory: String? = null,
    ): StorageVolume {
        val volume = Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.directory).thenReturn(directory?.let(::File))
            Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(this.uuid).thenReturn(uuid)
        }
        mounted[root] = volume
        return volume
    }

    /** A [StorageVolume] the device does not have mounted anywhere. */
    private fun unmountedVolume(uuid: String? = "9999-9999"): StorageVolume =
        Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.uuid).thenReturn(uuid)
            Mockito.`when`(this.isPrimary).thenReturn(false)
        }

    /** A [StorageVolume] reporting [uuid], which the manager mounts at [root]. */
    private fun volumeMountedAt(
        root: String,
        isPrimary: Boolean = false,
        uuid: String? = "1234-5678",
    ): StorageVolume = volumeOn(root, isPrimary, uuid, directory = root)

    init {
        // Below API 30 a candidate root is resolved by asking the manager which
        // volume sits there. `File` drops the trailing slash the resolver adds,
        // so a root answers for itself as well as for anything under it.
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenAnswer { answer ->
                val path = (answer.arguments.first() as File).absolutePath
                mounted.entries.firstOrNull { (root, _) ->
                    path == root || path.startsWith("$root/")
                }?.value
            }
    }

    private fun resolver(sdkInt: Int) = VolumePathResolver(context, storageManager, sdkInt)

    @Test
    fun `asks the volume for its directory on API 30 and above`() {
        val volume = volumeMountedAt("/storage/emulated/0", isPrimary = true)

        assertEquals("/storage/emulated/0", resolver(Build.VERSION_CODES.R).resolve(volume))
    }

    @Test
    fun `keeps asking the volume on API 30 and above even when the dirs would match`() {
        val volume = volumeMountedAt("/storage/self/primary", isPrimary = true)
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        // The legacy prefix match must not be consulted above the cutoff.
        assertEquals("/storage/self/primary", resolver(Build.VERSION_CODES.R).resolve(volume))
    }

    @Test
    fun `returns null on API 30 and above when the volume has no directory`() {
        val volume = volumeOn("/storage/emulated/0", isPrimary = true, directory = null)

        assertNull(resolver(Build.VERSION_CODES.R).resolve(volume))
    }

    // The primary volume below API 30 is resolved through
    // `Environment.getExternalStorageDirectory`, a static the unit-test runtime
    // does not implement, so that branch is not covered here.

    @Test
    fun `matches the volume root below API 30`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        val result = resolver(Build.VERSION_CODES.P)
            .resolve(volumeOn("/storage/emulated/0", isPrimary = false, uuid = "1111-1111"))

        // Trimmed of the four path segments below the root. No trailing slash:
        // `resolve` reports a bare root, and callers add the slash they need —
        // `MediaQueryBuilder` for its `LIKE`, `FileLocationResolver` for its
        // `substring`.
        assertEquals("/storage/emulated/0", result)
    }

    @Test
    fun `does not consult the volume below API 30`() {
        val volume = volumeOn("/storage/emulated/0", isPrimary = false, uuid = "1111-1111")
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        resolver(Build.VERSION_CODES.P).resolve(volume)

        Mockito.verify(volume, Mockito.never()).directory
    }

    @Test
    fun `picks the volume a UUID actually matches below API 30`() {
        externalDirs(
            "/storage/emulated/0/Android/data/com.example/files",
            "/storage/1234-5678/Android/data/com.example/files",
        )

        val result = resolver(Build.VERSION_CODES.P)
            .resolve(volumeOn("/storage/1234-5678", isPrimary = false, uuid = "1234-5678"))

        assertEquals("/storage/1234-5678", result)
    }

    @Test
    fun `matches a directory below API 30 despite its trailing slash`() {
        // The app dir carries a trailing slash; the root reported for it does not.
        externalDirs("/storage/1234-5678/Android/data/com.example/files/")

        val result = resolver(Build.VERSION_CODES.P)
            .resolve(volumeOn("/storage/1234-5678", isPrimary = false, uuid = "1234-5678"))

        assertEquals("/storage/1234-5678", result)
    }

    @Test
    fun `returns null below API 30 for a UUID no dir matches`() {
        externalDirs("/storage/1234-5678/Android/data/com.example/files")
        // A different volume is what the manager vouches for at that root, so
        // the UUID being looked up is on no known volume. The volume asked about
        // is deliberately left unmounted.
        volumeOn("/storage/1234-5678", isPrimary = false, uuid = "1111-1111")

        val result = resolver(Build.VERSION_CODES.P)
            .resolve(unmountedVolume(uuid = "9999-9999"))

        assertNull(result)
    }

    @Test
    fun `returns null below API 30 when the app has no external dirs`() {
        externalDirs()

        assertNull(
            resolver(Build.VERSION_CODES.P)
                .resolve(volumeOn("/storage/1234-5678", isPrimary = false, uuid = "1234-5678")),
        )
    }

    @Test
    fun `returns null below API 30 for a secondary volume with no UUID`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        assertNull(
            resolver(Build.VERSION_CODES.P)
                .resolve(volumeOn("/storage/emulated/0", isPrimary = false, uuid = null)),
        )
    }
}

/**
 * [FileLocationResolver] turns an absolute path into the volume it sits on, the
 * parent directory relative to the volume root, and the file name.
 *
 * A real [VolumePathResolver] sits underneath, so these tests also pin the
 * volume path it reports.
 */
internal class FileLocationResolverTest {
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)
    private val volume: StorageVolume = Mockito.mock(StorageVolume::class.java)
    private val context: Context = Mockito.mock(Context::class.java)

    private fun resolverOn(
        volumePath: String?,
        isPrimary: Boolean = true,
        uuid: String? = null,
    ) {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(volume)
        Mockito.`when`(volume.directory).thenReturn(volumePath?.let(::File))
        Mockito.`when`(volume.isPrimary).thenReturn(isPrimary)
        Mockito.`when`(volume.uuid).thenReturn(uuid)
    }

    /**
     * The volume path always comes from the volume's own directory, so the level
     * it is read at does not vary; pinning it here does not duplicate what
     * [VolumePathResolverTest] covers.
     */
    private fun resolve(path: String) =
        FileLocationResolver(
            storageManager,
            VolumePathResolver(context, storageManager, Build.VERSION_CODES.R),
        ).resolve(File(path))

    @Test
    fun `splits a path into its volume, relative parent and name`() {
        resolverOn("/storage/emulated/0", uuid = "1A2B-3C4D")

        assertEquals(
            FileLocation(
                volumeInfo = VolumeInfo(isPrimary = true, uuid = "1A2B-3C4D"),
                relativeParentPath = "DCIM/Camera/",
                fileNameWithExtension = "cat.png",
            ),
            resolve("/storage/emulated/0/DCIM/Camera/cat.png"),
        )
    }

    @Test
    fun `reports the volume a secondary file sits on`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = "1A2B-3C4D")

        val location = resolve("/storage/1234-5678/DCIM/cat.png")

        assertEquals(
            VolumeInfo(isPrimary = false, uuid = "1A2B-3C4D"),
            location?.volumeInfo,
        )
        assertEquals("DCIM/", location?.relativeParentPath)
    }

    @Test
    fun `reports a volume without a UUID rather than no volume at all`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = null)

        assertEquals(
            VolumeInfo(isPrimary = false, uuid = null),
            resolve("/storage/1234-5678/DCIM/cat.png")?.volumeInfo,
        )
    }

    @Test
    fun `reports an empty relative parent for a file in the volume root`() {
        resolverOn("/storage/emulated/0")

        assertEquals("", resolve("/storage/emulated/0/cat.png")?.relativeParentPath)
    }

    @Test
    fun `returns null when the volume is unknown`() {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(null)

        assertNull(resolve("/storage/emulated/0/DCIM/cat.png"))
    }

    @Test
    fun `returns null when the volume has no directory`() {
        resolverOn(volumePath = null)

        assertNull(resolve("/storage/emulated/0/DCIM/cat.png"))
    }
}

/**
 * The path helpers the resolvers are built from. The slash matters in both
 * directions: a prefix match needs one, and `substring` must not eat a character
 * of the relative path.
 */
internal class PathExtensionsTest {
    @Test
    fun `ensureTrailingSlash leaves an existing slash alone`() {
        assertEquals("/DCIM/", "/DCIM/".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash adds a missing slash`() {
        assertEquals("/DCIM/", "/DCIM".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash keeps the root slash`() {
        assertEquals("/", "/".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash turns an empty string into the root`() {
        // Nothing to anchor to, so the helper falls back to the root. Callers
        // never pass an empty path, so this only pins the current behaviour.
        assertEquals(File.separator, "".ensureTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash drops an existing slash`() {
        assertEquals("/DCIM", "/DCIM/".ensureNoTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash leaves a slashless string alone`() {
        assertEquals("/DCIM", "/DCIM".ensureNoTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash turns the root into an empty string`() {
        assertEquals("", "/".ensureNoTrailingSlash())
    }
}