package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.content.Context
import android.os.Build
import android.os.StatFs
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.fakes.volumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

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
        isRemovable: Boolean = false,
    ) {
        Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
            .thenReturn(volume)
        Mockito.`when`(volume.directory).thenReturn(volumePath?.let(::File))
        Mockito.`when`(volume.isPrimary).thenReturn(isPrimary)
        Mockito.`when`(volume.uuid).thenReturn(uuid)
        Mockito.`when`(volume.isRemovable).thenReturn(isRemovable)
        // Only the primary volume is emulated, so the secondary tests below
        // report the default `false` a bare mock hands back.
        Mockito.`when`(volume.isEmulated).thenReturn(isPrimary)
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
            // Stateless; which volume type it reports is VolumeTypeResolverTest's
            // business. On a mock it reports UNKNOWN/UNKNOWN_REMOVABLE, which is
            // what the expectations below assert.
            VolumeTypeResolver(),
        ).resolve(path)

    @Test
    fun `reports a file whose volume size cannot be read rather than failing`() {
        // A file on a volume whose filesystem has gone away must still be
        // reported: the resolver reports what it can, with no capacity, rather
        // than dropping the file out of the media list.
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = "1A2B-3C4D")
        Mockito.mockConstruction(StatFs::class.java) { _, _ ->
            throw IllegalArgumentException("path does not exist")
        }.use {
            val location = resolve("/storage/1234-5678/DCIM/cat.png")

            assertEquals(0, location?.volumeIdentity?.capacityInBytes)
            assertEquals("DCIM/", location?.relativeParentPath)
        }
    }

    @Test
    fun `splits a path into its volume, relative parent and name`() {
        resolverOn("/storage/emulated/0", uuid = "1A2B-3C4D")

        assertEquals(
            FileLocation(
                volumeIdentity = volumeIdentity(isPrimary = true, uuid = "1A2B-3C4D"),
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
            volumeIdentity(
                isPrimary = false,
                uuid = "1A2B-3C4D",
                isEmulated = false,
                type = VolumeType.UNKNOWN,
            ),
            location?.volumeIdentity,
        )
        assertEquals("DCIM/", location?.relativeParentPath)
    }

    @Test
    fun `reports a volume without a UUID rather than no volume at all`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = null)

        assertEquals(
            volumeIdentity(
                isPrimary = false,
                uuid = null,
                isEmulated = false,
                type = VolumeType.UNKNOWN,
            ),
            resolve("/storage/1234-5678/DCIM/cat.png")?.volumeIdentity,
        )
    }

    @Test
    fun `reports a removable volume whose type cannot be told apart`() {
        resolverOn("/storage/1234-5678", isPrimary = false, uuid = "1A2B-3C4D", isRemovable = true)

        // No block device id is readable off a mock, so SD and USB stay apart.
        assertEquals(
            volumeIdentity(
                isPrimary = false,
                uuid = "1A2B-3C4D",
                isRemovable = true,
                isEmulated = false,
                type = VolumeType.UNKNOWN_REMOVABLE,
            ),
            resolve("/storage/1234-5678/DCIM/cat.png")?.volumeIdentity,
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
