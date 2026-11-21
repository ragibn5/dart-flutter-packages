package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Makes a video's thumbnail from a frame of the video itself, for documents whose provider
 * makes none.
 *
 * Note: A document provider that doesn't flag thumbnail support, such as Android's external
 * storage provider for videos, answers a thumbnail request with the whole file instead.
 */
internal class VideoFrameThumbnails(private val context: Context) {
    /**
     * Whether [uri] is a video document whose provider doesn't make thumbnails.
     *
     * @throws SecurityException if the app can't read [uri].
     */
    fun isNeeded(uri: Uri): Boolean {
        if (!DocumentsContract.isDocumentUri(context, uri)) {
            return false
        }
        val type = context.contentResolver.getType(uri) ?: return false
        if (!type.startsWith("video/")) {
            return false
        }

        val flags = context.contentResolver
            .query(uri, arrayOf(Document.COLUMN_FLAGS), null, null, null)
            ?.use { cursor -> if (cursor.moveToFirst()) cursor.getInt(0) else null }
            ?: return false
        return flags and Document.FLAG_SUPPORTS_THUMBNAIL == 0
    }

    /**
     * Reads a frame of the video at [uri], fitted within [width] by [height], as JPEG bytes.
     *
     * @throws FileNotFoundException if no frame can be read from it.
     * @throws SecurityException if the app can't read [uri].
     */
    @Throws(FileNotFoundException::class)
    fun readFrameAsJpeg(uri: Uri, width: Int, height: Int): ByteArray {
        val retriever = MediaMetadataRetriever()
        try {
            val frame = try {
                retriever.setDataSource(context, uri)
                readFrame(retriever, width, height)
            } catch (e: SecurityException) {
                throw e
            } catch (e: RuntimeException) {
                // The retriever reports content it can't read as a plain RuntimeException
                // ("setDataSource failed"), or as an IllegalArgumentException.
                throw noFrame(uri, e)
            } ?: throw noFrame(uri)

            return ByteArrayOutputStream().use { output ->
                frame.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, output)
                frame.recycle()
                output.toByteArray()
            }
        } finally {
            retriever.release()
        }
    }

    private fun readFrame(retriever: MediaMetadataRetriever, width: Int, height: Int): Bitmap? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            return retriever.getScaledFrameAtTime(
                -1,
                MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                width,
                height,
            )
        }

        val frame = retriever.frameAtTime ?: return null
        val scale = min(width.toFloat() / frame.width, height.toFloat() / frame.height)
        if (scale >= 1f) {
            return frame
        }
        val scaled = Bitmap.createScaledBitmap(
            frame,
            (frame.width * scale).roundToInt().coerceAtLeast(1),
            (frame.height * scale).roundToInt().coerceAtLeast(1),
            true,
        )
        frame.recycle()
        return scaled
    }

    private fun noFrame(uri: Uri, cause: Throwable? = null) =
        FileNotFoundException("No frame can be read from the video at $uri").apply {
            if (cause != null) {
                initCause(cause)
            }
        }

    private companion object {
        private const val JPEG_QUALITY = 90
    }
}
