package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import android.provider.MediaStore
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [VolumePathResolver] finds the storage volume root a file sits under.
 *
 * On API 30 and above it asks `StorageManager`; below that it only has the app's
 * external files dirs to go on, so it matches a prefix against them. Both
 * branches are covered by pinning the SDK level, and the paths are absolute so
 * the result never depends on the machine running the tests.
 */
internal class VolumePathResolverTest {
    private val context: Context = Mockito.mock(Context::class.java)
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)
    private val volume: StorageVolume = Mockito.mock(StorageVolume::class.java)

    /**
     * `getExternalFilesDirs` returns the per-app dirs, which sit four segments
     * below the volume root.
     */
    private fun externalDirs(vararg dirs: String) {
        Mockito.`when`(context.getExternalFilesDirs(Mockito.any()))
            .thenReturn(dirs.map(::File).toTypedArray())
    }

    private fun storageVolumeAt(path: String?) {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(volume)
        Mockito.`when`(volume.directory).thenReturn(path?.let(::File))
    }

    private fun resolver(sdkInt: Int) = VolumePathResolver(context, storageManager, sdkInt)

    @Test
    fun `asks StorageManager for the volume on API 30 and above`() {
        storageVolumeAt("/storage/emulated/0")

        val result = resolver(Build.VERSION_CODES.R).resolve(
            File("/storage/emulated/0/DCIM/cat.png"),
        )

        assertEquals("/storage/emulated/0", result)
        Mockito.verify(storageManager).getStorageVolume(
            File("/storage/emulated/0/DCIM/cat.png"),
        )
    }

    @Test
    fun `keeps asking StorageManager on API 30 and above even when the dirs would match`() {
        storageVolumeAt("/storage/self/primary")
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        val result = resolver(Build.VERSION_CODES.R).resolve(
            File("/storage/emulated/0/DCIM/cat.png"),
        )

        // The legacy prefix match must not be consulted above the cutoff.
        assertEquals("/storage/self/primary", result)
    }

    @Test
    fun `returns null on API 30 and above when StorageManager knows no volume`() {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(null)

        assertNull(resolver(Build.VERSION_CODES.R).resolve(File("/storage/emulated/0/DCIM")))
    }

    @Test
    fun `returns null on API 30 and above when the volume has no directory`() {
        storageVolumeAt(null)

        assertNull(resolver(Build.VERSION_CODES.R).resolve(File("/storage/emulated/0/DCIM")))
    }

    @Test
    fun `matches the volume root below API 30`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        val result = resolver(Build.VERSION_CODES.P).resolve(
            File("/storage/emulated/0/DCIM/Camera/cat.png"),
        )

        // Trimmed of the four path segments below the root, and of the trailing
        // slash the prefix match needs.
        assertEquals("/storage/emulated/0", result)
    }

    @Test
    fun `does not consult StorageManager below API 30`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        resolver(Build.VERSION_CODES.P).resolve(File("/storage/emulated/0/DCIM/cat.png"))

        Mockito.verify(storageManager, Mockito.never())
            .getStorageVolume(Mockito.any(File::class.java))
    }

    @Test
    fun `picks the volume a file actually sits on below API 30`() {
        externalDirs(
            "/storage/emulated/0/Android/data/com.example/files",
            "/storage/1234-5678/Android/data/com.example/files",
        )

        val result = resolver(Build.VERSION_CODES.P).resolve(
            File("/storage/1234-5678/DCIM/cat.png"),
        )

        assertEquals("/storage/1234-5678", result)
    }

    @Test
    fun `matches a directory below API 30 despite its trailing slash`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        val result = resolver(Build.VERSION_CODES.P).resolve(File("/storage/emulated/0/DCIM"))

        assertEquals("/storage/emulated/0", result)
    }

    @Test
    fun `does not match a sibling volume that only shares a prefix below API 30`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        // "/storage/emulated/01" starts with "/storage/emulated/0" but is a
        // different volume, so it must not match.
        val result = resolver(Build.VERSION_CODES.P).resolve(
            File("/storage/emulated/01/DCIM/cat.png"),
        )

        assertNull(result)
    }

    @Test
    fun `returns null below API 30 for a file on no known volume`() {
        externalDirs("/storage/emulated/0/Android/data/com.example/files")

        val result = resolver(Build.VERSION_CODES.P).resolve(
            File("/data/media/0/DCIM/cat.png"),
        )

        assertNull(result)
    }

    @Test
    fun `returns null below API 30 when the app has no external dirs`() {
        externalDirs()

        assertNull(resolver(Build.VERSION_CODES.P).resolve(File("/storage/emulated/0/DCIM")))
    }
}

/**
 * [FileLocationResolver] turns an absolute path into the volume name, the
 * parent directory relative to the volume root, and the file name.
 *
 * A real [VolumePathResolver] sits underneath, so these tests also pin the
 * volume path it reports.
 */
internal class FileLocationResolverTest {
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)
    private val volume: StorageVolume = Mockito.mock(StorageVolume::class.java)
    private val context: Context = Mockito.mock(Context::class.java)

    private fun resolverOn(volumePath: String?, isPrimary: Boolean = true, uuid: String? = null) {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(volume)
        Mockito.`when`(volume.directory).thenReturn(volumePath?.let(::File))
        Mockito.`when`(volume.isPrimary).thenReturn(isPrimary)
        Mockito.`when`(volume.uuid).thenReturn(uuid)
    }

    private fun resolve(path: String) =
        FileLocationResolver(
            storageManager,
            VolumePathResolver(context, storageManager, Build.VERSION_CODES.R),
        ).resolve(File(path))

    @Test
    fun `splits a path into its volume, relative parent and name`() {
        resolverOn("/storage/emulated/0")

        assertEquals(
            FileLocation(
                volumeName = MediaStore.VOLUME_EXTERNAL_PRIMARY,
                relativeParentPath = "DCIM/Camera/",
                fileNameWithExtension = "cat.png",
            ),
            resolve("/storage/emulated/0/DCIM/Camera/cat.png"),
        )
    }

    @Test
    fun `names the primary volume rather than leaving it null`() {
        resolverOn("/storage/emulated/0", isPrimary = true, uuid = null)

        // `null` is reserved for "no volume", so the primary volume is named.
        assertEquals(
            MediaStore.VOLUME_EXTERNAL_PRIMARY,
            resolve("/storage/emulated/0/DCIM/cat.png")?.volumeName,
        )
    }

    @Test
    fun `reports an empty relative parent for a file in the volume root`() {
        resolverOn("/storage/emulated/0")

        assertEquals("", resolve("/storage/emulated/0/cat.png")?.relativeParentPath)
    }

    @Test
    fun `lowercases the UUID of a secondary volume into the volume name`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = "1A2B-3C4D")

        val location = resolve("/storage/1234-5678/DCIM/cat.png")

        assertEquals("1a2b-3c4d", location?.volumeName)
        assertEquals("DCIM/", location?.relativeParentPath)
    }

    @Test
    fun `reports no volume name for a secondary volume without a UUID`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = null)

        assertNull(resolve("/storage/1234-5678/DCIM/cat.png")?.volumeName)
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