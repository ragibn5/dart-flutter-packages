package com.ragibn5.content.io.content_io_android.features.read.services

import android.media.ExifInterface
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ThumbnailSize
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class ThumbnailRulesTest {
    private val request = OpenThumbnailReadRequest(URI, ThumbnailSize(256, 256))

    @Test
    fun getSampleSizeShouldBeTheLargerSideRatio() {
        assertEquals(15, ThumbnailRules.getSampleSize(4080, 2296, request))
    }

    @Test
    fun getSampleSizeShouldBeOneIfImageIsSmallerThanRequested() {
        assertEquals(1, ThumbnailRules.getSampleSize(200, 100, request))
    }

    @Test
    fun getSampleSizeShouldBeOneIfRequestDoesntScaleDown() {
        assertEquals(1, ThumbnailRules.getSampleSize(4080, 2296, request.copy(scaleDownToSize = false)))
    }

    @Test
    fun getPowerOfTwoSampleSizeShouldRoundDownToPowerOfTwo() {
        assertEquals(8, ThumbnailRules.getPowerOfTwoSampleSize(15))
    }

    @Test
    fun getScaledLengthShouldDivideBySampleSize() {
        assertEquals(272, ThumbnailRules.getScaledLength(4080, 15))
    }

    @Test
    fun getScaledLengthShouldBeAtLeastOne() {
        assertEquals(1, ThumbnailRules.getScaledLength(3, 15))
    }

    @Test
    fun getRotationShouldNormaliseDegrees() {
        assertEquals(270, ThumbnailRules.getRotation(-90, request))
    }

    @Test
    fun getRotationShouldBeZeroIfRequestDoesntRotate() {
        assertEquals(0, ThumbnailRules.getRotation(90, request.copy(rotateUpright = false)))
    }

    @Test
    fun getExifRotationShouldBeTheDegreesOfRotatingOrientations() {
        assertEquals(
            listOf(90, 180, 270),
            listOf(
                ExifInterface.ORIENTATION_ROTATE_90,
                ExifInterface.ORIENTATION_ROTATE_180,
                ExifInterface.ORIENTATION_ROTATE_270,
            ).map(ThumbnailRules::getExifRotation),
        )
    }

    @Test
    fun getExifRotationShouldBeZeroIfOrientationMirrors() {
        assertEquals(0, ThumbnailRules.getExifRotation(ExifInterface.ORIENTATION_TRANSPOSE))
    }

    @Test
    fun isUnchangedShouldBeTrueIfNeitherScaledNorRotated() {
        assertTrue(ThumbnailRules.isUnchanged(sampleSize = 1, rotation = 0))
    }

    @Test
    fun isUnchangedShouldBeFalseIfScaled() {
        assertFalse(ThumbnailRules.isUnchanged(sampleSize = 2, rotation = 0))
    }

    @Test
    fun isUnchangedShouldBeFalseIfRotated() {
        assertFalse(ThumbnailRules.isUnchanged(sampleSize = 1, rotation = 90))
    }

    @Test
    fun isHeifShouldBeTrueForHeicBrand() {
        assertTrue(ThumbnailRules.isHeif(header("ftyp", "heic")))
    }

    @Test
    fun isHeifShouldBeTrueForAvifBrand() {
        assertTrue(ThumbnailRules.isHeif(header("ftyp", "avif")))
    }

    @Test
    fun isHeifShouldBeFalseForOtherBrand() {
        assertFalse(ThumbnailRules.isHeif(header("ftyp", "isom")))
    }

    @Test
    fun isHeifShouldBeFalseWithoutFileTypeBox() {
        assertFalse(ThumbnailRules.isHeif(header("moov", "heic")))
    }

    @Test
    fun isHeifShouldBeFalseIfHeaderIsShort() {
        assertFalse(ThumbnailRules.isHeif(byteArrayOf(0, 0, 0, 24)))
    }

    /** A container's first 12 bytes: a size, [box] and [brand]. */
    private fun header(box: String, brand: String): ByteArray =
        byteArrayOf(0, 0, 0, 24) + box.toByteArray(Charsets.US_ASCII) + brand.toByteArray(Charsets.US_ASCII)

    private companion object {
        const val URI = "content://media/external/images/media/1"
    }
}
