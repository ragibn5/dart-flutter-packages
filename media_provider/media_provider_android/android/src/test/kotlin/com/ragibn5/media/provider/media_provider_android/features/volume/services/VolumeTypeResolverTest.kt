package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class VolumeTypeResolverTest {
    private val resolver = VolumeTypeResolver()

    @Test
    fun resolveShouldReturnUnknownRemovableIfVolumeIdCanNotBeRead() {
        // The SDK stub has no hidden `getId`, as on a platform that blocks it.
        val volume = Mockito.mock(StorageVolume::class.java)
        Mockito.`when`(volume.isRemovable).thenReturn(true)

        assertEquals(VolumeType.UNKNOWN_REMOVABLE, resolver.resolve(volume))
    }

    @Test
    fun resolveShouldReturnPrimaryIfVolumeIsPrimary() {
        assertEquals(
            VolumeType.PRIMARY,
            resolver.resolve(isPrimary = true, isRemovable = true, blockMajor = VolumeTypeResolver.MAJOR_MMC),
        )
    }

    @Test
    fun resolveShouldReturnUnknownIfVolumeIsNotRemovable() {
        assertEquals(
            VolumeType.UNKNOWN,
            resolver.resolve(isPrimary = false, isRemovable = false, blockMajor = VolumeTypeResolver.MAJOR_MMC),
        )
    }

    @Test
    fun resolveShouldReturnSdCardIfBlockMajorIsMmc() {
        assertEquals(
            VolumeType.SD_CARD,
            resolver.resolve(isPrimary = false, isRemovable = true, blockMajor = VolumeTypeResolver.MAJOR_MMC),
        )
    }

    @Test
    fun resolveShouldReturnUsbDriveIfBlockMajorIsScsiDisk() {
        assertEquals(
            VolumeType.USB_DRIVE,
            resolver.resolve(isPrimary = false, isRemovable = true, blockMajor = VolumeTypeResolver.MAJOR_SCSI_DISK),
        )
    }

    @Test
    fun resolveShouldReturnUnknownRemovableIfBlockMajorIsOther() {
        assertEquals(
            VolumeType.UNKNOWN_REMOVABLE,
            resolver.resolve(isPrimary = false, isRemovable = true, blockMajor = 259),
        )
    }

    @Test
    fun parseBlockMajorShouldReturnMajorIfIdIsPublic() {
        assertEquals(179, resolver.parseBlockMajor("public:179,65"))
    }

    @Test
    fun parseBlockMajorShouldReturnNullIfIdIsNull() {
        assertNull(resolver.parseBlockMajor(null))
    }

    @Test
    fun parseBlockMajorShouldReturnNullIfIdIsNotPublic() {
        assertNull(resolver.parseBlockMajor("emulated;0"))
    }
}
