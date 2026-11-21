package com.ragibn5.content.io.content_io_android.features.read.services

import android.graphics.Bitmap
import android.graphics.Matrix
import java.io.ByteArrayOutputStream

/**
 * Scales, rotates and encodes thumbnail bitmaps.
 */
internal object ThumbnailBitmaps {
    private const val JPEG_QUALITY = 90

    /**
     * Scales [bitmap] to [width] by [height], recycling it if a new one is made.
     *
     * @return [bitmap] itself if it's already that size.
     */
    fun scale(bitmap: Bitmap, width: Int, height: Int): Bitmap {
        if (bitmap.width == width && bitmap.height == height) {
            return bitmap
        }
        val scaled = Bitmap.createScaledBitmap(bitmap, width, height, true)
        if (scaled !== bitmap) {
            bitmap.recycle()
        }
        return scaled
    }

    /**
     * Rotates [bitmap] clockwise by [degrees], recycling it if a new one is made.
     *
     * @return [bitmap] itself if [degrees] is 0.
     */
    fun rotate(bitmap: Bitmap, degrees: Int): Bitmap {
        if (degrees % 360 == 0) {
            return bitmap
        }
        val matrix = Matrix().apply { setRotate(degrees.toFloat()) }
        val rotated = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        if (rotated !== bitmap) {
            bitmap.recycle()
        }
        return rotated
    }

    /**
     * Encodes [bitmap], then recycles it.
     *
     * @param canBeTransparent whether [bitmap] may hold transparency worth keeping; a video
     * frame never does, though its bitmap may say it has an alpha channel.
     * @return PNG bytes if it can be transparent and has an alpha channel, so it isn't lost;
     * JPEG bytes otherwise.
     */
    fun encode(bitmap: Bitmap, canBeTransparent: Boolean): ByteArray {
        val format = if (canBeTransparent && bitmap.hasAlpha()) {
            Bitmap.CompressFormat.PNG
        } else {
            Bitmap.CompressFormat.JPEG
        }
        return ByteArrayOutputStream().use { output ->
            bitmap.compress(format, JPEG_QUALITY, output)
            bitmap.recycle()
            output.toByteArray()
        }
    }
}
