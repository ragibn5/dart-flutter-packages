package com.ragibn5.content.io.content_io_android.features.read.services

import android.media.ExifInterface
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import kotlin.math.max

/**
 * The rules for fitting a thumbnail to a request, the same as
 * [android.content.ContentResolver.loadThumbnail]'s.
 */
internal object ThumbnailRules {
    /**
     * The whole-number factor to scale an image of [width] by [height] down by.
     *
     * @return the larger of `width / requested width` and `height / requested height`,
     * at least 1; 1 if [request] doesn't scale down.
     *
     * Note: The longer side stays at least the requested size; the shorter one may end up
     * below it.
     */
    fun getSampleSize(width: Int, height: Int, request: OpenThumbnailReadRequest): Int {
        if (!request.scaleDownToSize) {
            return 1
        }
        return max(width / request.size.width, height / request.size.height).coerceAtLeast(1)
    }

    /** The largest power of two that is at most [sampleSize], as image decoders sample by. */
    fun getPowerOfTwoSampleSize(sampleSize: Int): Int =
        Integer.highestOneBit(sampleSize.coerceAtLeast(1))

    /** The size, in pixels, of [length] scaled down by [sampleSize]; at least 1. */
    fun getScaledLength(length: Int, sampleSize: Int): Int =
        (length / sampleSize.coerceAtLeast(1)).coerceAtLeast(1)

    /**
     * The degrees to rotate by, clockwise, for [rotation] degrees asked; 0 if [request]
     * doesn't rotate.
     */
    fun getRotation(rotation: Int, request: OpenThumbnailReadRequest): Int {
        if (!request.rotateUpright) {
            return 0
        }
        return ((rotation % 360) + 360) % 360
    }

    /**
     * The degrees an EXIF [orientation] rotates by, clockwise; 0 for none, or for one that
     * also mirrors.
     */
    fun getExifRotation(orientation: Int): Int = when (orientation) {
        ExifInterface.ORIENTATION_ROTATE_90 -> 90
        ExifInterface.ORIENTATION_ROTATE_180 -> 180
        ExifInterface.ORIENTATION_ROTATE_270 -> 270
        else -> 0
    }

    /** The brands of HEIF containers, HEIC and AVIF among them, at bytes 8 to 11. */
    private val HEIF_BRANDS = setOf(
        "heic", "heix", "hevc", "hevx", "heim", "heis", "mif1", "msf1", "avif", "avis",
    )

    /**
     * Whether [header], an image's first 12 bytes or more, is a HEIF container's.
     *
     * Note: A HEIF image is rotated by its container ('irot'), which the standard makes
     * authoritative; its EXIF orientation tag is only informative and may disagree.
     */
    fun isHeif(header: ByteArray): Boolean {
        if (header.size < 12 || String(header, 4, 4, Charsets.US_ASCII) != "ftyp") {
            return false
        }
        return String(header, 8, 4, Charsets.US_ASCII) in HEIF_BRANDS
    }

    /** Whether a thumbnail sampled by [sampleSize] and rotated by [rotation] needs no change. */
    fun isUnchanged(sampleSize: Int, rotation: Int): Boolean = sampleSize <= 1 && rotation == 0
}
