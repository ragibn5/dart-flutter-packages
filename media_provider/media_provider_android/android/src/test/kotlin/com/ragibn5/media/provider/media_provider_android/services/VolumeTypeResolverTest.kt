package com.ragibn5.media.provider.media_provider_android.services

import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.models.VolumeType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [VolumeTypeResolver] classifies a [StorageVolume] as primary, an SD card, a USB
 * drive, or something it cannot tell apart.
 *
 * The volume's own block-device id comes from `getId`, which is hidden and so
 * absent from the SDK stub jar the unit tests run against: no volume can be made
 * to report one. Both halves the id feeds — parsing it, and classifying from the
 * result — are therefore pinned here directly, and the single end-to-end case
 * (`resolve(StorageVolume)`) is pinned at the value a real unreadable id yields.
 */
internal class VolumeTypeResolverTest {
    /** The resolver under test. It holds no state, so one instance serves all. */
    private val resolver = VolumeTypeResolver()

    /** Classify the volume the way [VolumeTypeResolver.resolve] does. */
    private fun classify(blockMajor: Int?, isPrimary: Boolean = false, isRemovable: Boolean = true) =
        resolver.resolve(
            isPrimary = isPrimary,
            isRemovable = isRemovable,
            blockMajor = blockMajor,
        )

    @Test
    fun `reports the primary volume whatever else it is`() {
        // Primary wins over every other fact, since it is asked first.
        assertEquals(
            VolumeType.PRIMARY,
            classify(blockMajor = null, isPrimary = true, isRemovable = true),
        )
        assertEquals(
            VolumeType.PRIMARY,
            classify(VolumeTypeResolver.MAJOR_MMC, isPrimary = true, isRemovable = false),
        )
    }

    @Test
    fun `reports a fixed secondary volume as unknown`() {
        assertEquals(VolumeType.UNKNOWN, classify(blockMajor = null, isRemovable = false))
    }

    @Test
    fun `reports an mmc block device as an SD card`() {
        assertEquals(VolumeType.SD_CARD, classify(VolumeTypeResolver.MAJOR_MMC))
    }

    @Test
    fun `reports a SCSI block device as a USB drive`() {
        assertEquals(VolumeType.USB_DRIVE, classify(VolumeTypeResolver.MAJOR_SCSI_DISK))
    }

    @Test
    fun `reports any other removable volume as an unknown one`() {
        assertEquals(VolumeType.UNKNOWN_REMOVABLE, classify(blockMajor = null))
        assertEquals(VolumeType.UNKNOWN_REMOVABLE, classify(VolumeTypeResolver.MAJOR_SCSI_DISK + 1))
    }

    @Test
    fun `reads the major off a public volume id`() {
        assertEquals(179, resolver.parseBlockMajor("public:179,65"))
        // Only the major decides; the minor is ignored, so two minors on one
        // major are the same volume as far as classification goes.
        assertEquals(8, resolver.parseBlockMajor("public:8,1"))
        assertEquals(8, resolver.parseBlockMajor("public:8,65"))
    }

    @Test
    fun `reads no major off a missing or foreign id`() {
        assertNull(resolver.parseBlockMajor(null))
        // Private volumes are not addressed by `public:` at all, and a well-formed
        // id of another scheme carries no block major to read.
        assertNull(resolver.parseBlockMajor("private:179,65"))
        assertNull(resolver.parseBlockMajor(""))
    }

    @Test
    fun `reads no major off an id that is not exactly the public form`() {
        // `matchEntire`, so no leading or trailing text may be present, and both
        // numbers must be present — a partial id is not trusted.
        assertNull(resolver.parseBlockMajor("public:179"))
        assertNull(resolver.parseBlockMajor(" public:179,65"))
        assertNull(resolver.parseBlockMajor("public:179,65 "))
        assertNull(resolver.parseBlockMajor("prefix public:179,65"))
        assertNull(resolver.parseBlockMajor("public:,65"))
    }

    @Test
    fun `classifies a real volume with no readable block major`() {
        // The one end-to-end case available: `getId` is missing from the stub jar,
        // so `resolve` sees a null major for every volume, as it does on a device
        // where the platform blocks the call.
        val primary = Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(true)
            Mockito.`when`(this.isRemovable).thenReturn(false)
        }
        val removable = Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(false)
            Mockito.`when`(this.isRemovable).thenReturn(true)
        }
        val fixed = Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(false)
            Mockito.`when`(this.isRemovable).thenReturn(false)
        }

        assertEquals(VolumeType.PRIMARY, resolver.resolve(primary))
        assertEquals(VolumeType.UNKNOWN_REMOVABLE, resolver.resolve(removable))
        assertEquals(VolumeType.UNKNOWN, resolver.resolve(fixed))
    }
}