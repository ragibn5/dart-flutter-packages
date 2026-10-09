package com.ragibn5.media.provider.media_provider_android.services

import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [VolumeInfoResolver] looks a volume up by the name a `VOLUME_NAME` column
 * reports for it.
 *
 * The name is read off the volume itself from API 30 on, and derived below that,
 * so both branches are covered by pinning the SDK level.
 */
internal class VolumeInfoResolverTest {
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)

    /**
     * Reports [volumes] as the device's storage, each reporting the name it would
     * be asked for at whatever level the resolver is pinned to.
     */
    private fun storageVolumes(vararg volumes: StorageVolume) {
        Mockito.`when`(storageManager.storageVolumes).thenReturn(volumes.toList())
    }

    private fun volumeOn(
        mediaStoreVolumeName: String? = MediaStore.VOLUME_EXTERNAL_PRIMARY,
        isPrimary: Boolean = true,
        uuid: String? = null,
    ): StorageVolume = Mockito.mock(StorageVolume::class.java).apply {
        Mockito.`when`(this.mediaStoreVolumeName).thenReturn(mediaStoreVolumeName)
        Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
        Mockito.`when`(this.uuid).thenReturn(uuid)
    }

    private fun fromName(volumeName: String, sdkInt: Int = Build.VERSION_CODES.R) =
        VolumeInfoResolver(storageManager, sdkInt).fromName(volumeName)

    @Test
    fun `resolves a volume by the name it reports on API 30 and above`() {
        storageVolumes(
            volumeOn(
                mediaStoreVolumeName = "1234-5678",
                isPrimary = false,
                uuid = "1A2B"
            )
        )

        assertEquals(VolumeInfo(isPrimary = false, uuid = "1A2B"), fromName("1234-5678"))
    }

    @Test
    fun `resolves the primary volume by its own name`() {
        storageVolumes(volumeOn(mediaStoreVolumeName = MediaStore.VOLUME_EXTERNAL_PRIMARY))

        assertEquals(
            VolumeInfo(isPrimary = true, uuid = null),
            fromName(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        )
    }

    @Test
    fun `picks the matching volume when several are mounted`() {
        storageVolumes(
            volumeOn(mediaStoreVolumeName = "1111-1111"),
            volumeOn(mediaStoreVolumeName = "2222-2222", isPrimary = false, uuid = "B2"),
            volumeOn(mediaStoreVolumeName = "3333-3333", isPrimary = false, uuid = "C3"),
        )

        assertEquals(VolumeInfo(isPrimary = false, uuid = "C3"), fromName("3333-3333"))
    }

    @Test
    fun `returns null when no mounted volume carries the name`() {
        storageVolumes(volumeOn(mediaStoreVolumeName = "1111-1111"))

        assertNull(fromName("2222-2222"))
    }

    @Test
    fun `returns null when the device reports no volumes`() {
        storageVolumes()

        assertNull(fromName(MediaStore.VOLUME_EXTERNAL_PRIMARY))
    }

    @Test
    fun `resolves the primary volume by its derived name below API 30`() {
        storageVolumes(volumeOn(mediaStoreVolumeName = null, isPrimary = true))

        assertEquals(
            VolumeInfo(isPrimary = true, uuid = null),
            fromName(MediaStore.VOLUME_EXTERNAL_PRIMARY, sdkInt = Build.VERSION_CODES.P),
        )
    }

    @Test
    fun `matches a secondary volume by its lowercased UUID below API 30`() {
        storageVolumes(
            volumeOn(mediaStoreVolumeName = null, isPrimary = false, uuid = "1A2B-3C4D"),
        )

        assertEquals(
            VolumeInfo(isPrimary = false, uuid = "1A2B-3C4D"),
            fromName("1a2b-3c4d", sdkInt = Build.VERSION_CODES.P),
        )
    }

    @Test
    fun `returns null for a secondary volume with no UUID below API 30`() {
        // Nothing derives a name from a volume that has neither.
        storageVolumes(volumeOn(mediaStoreVolumeName = null, isPrimary = false, uuid = null))

        assertNull(fromName("1a2b-3c4d", sdkInt = Build.VERSION_CODES.P))
    }

    @Test
    fun `ignores the API 30 name below API 30`() {
        storageVolumes(
            volumeOn(
                mediaStoreVolumeName = "1234-5678",
                isPrimary = false,
                uuid = "1A2B"
            )
        )

        assertNull(fromName("1234-5678", sdkInt = Build.VERSION_CODES.P))
    }
}