package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import java.io.FileNotFoundException
import kotlin.math.max

/**
 * Makes a video's thumbnail from a frame of the video itself, by [ThumbnailRules].
 */
internal class VideoFrameThumbnails(private val context: Context) {
    /**
     * Makes a thumbnail for [request] from a representative frame of the video at [uri].
     *
     * @throws FileNotFoundException if no frame can be read from it.
     * @throws SecurityException if the app can't read [uri].
     *
     * Note: The retriever returns frames upright, by the video's rotation; a request that
     * doesn't rotate gets the frame turned back.
     */
    @Throws(FileNotFoundException::class)
    fun makeFromVideo(uri: Uri, request: OpenThumbnailReadRequest): ByteArray {
        val retriever = MediaMetadataRetriever()
        try {
            val (frame, rotation) = try {
                retriever.setDataSource(context, uri)
                readFrame(retriever, request)
            } catch (e: SecurityException) {
                throw e
            } catch (e: RuntimeException) {
                // The retriever reports content it can't read as a plain RuntimeException
                // ("setDataSource failed"), or as an IllegalArgumentException.
                throw noFrame(uri, e)
            } ?: throw noFrame(uri)

            val turnedBack = if (request.rotateUpright) frame else ThumbnailBitmaps.rotate(frame, -rotation)
            return ThumbnailBitmaps.encode(turnedBack, canBeTransparent = false)
        } finally {
            retriever.release()
        }
    }

    /**
     * Reads a frame fitted to [request], and the video's rotation.
     *
     * @return `null` if the video has no frame to read.
     */
    private fun readFrame(
        retriever: MediaMetadataRetriever,
        request: OpenThumbnailReadRequest,
    ): Pair<Bitmap, Int>? {
        val width = retriever.extractInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH) ?: return null
        val height = retriever.extractInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT) ?: return null
        val rotation = retriever.extractInt(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) ?: 0
        // Frames come upright, so they're fitted as shown.
        val isTurned = rotation % 180 != 0
        val shownWidth = if (isTurned) height else width
        val shownHeight = if (isTurned) width else height

        val sampleSize = ThumbnailRules.getSampleSize(shownWidth, shownHeight, request)
        val targetWidth = ThumbnailRules.getScaledLength(shownWidth, sampleSize)
        val targetHeight = ThumbnailRules.getScaledLength(shownHeight, sampleSize)

        val frame = if (sampleSize > 1 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            // Fitted within a square of the longer side, so the frame's own orientation
            // doesn't matter.
            val box = max(targetWidth, targetHeight)
            retriever.getScaledFrameAtTime(-1, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, box, box)
        } else {
            retriever.getFrameAtTime(-1, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                ?.let {
                    // By the frame's own size, in case it isn't turned as shown.
                    ThumbnailBitmaps.scale(
                        it,
                        ThumbnailRules.getScaledLength(it.width, sampleSize),
                        ThumbnailRules.getScaledLength(it.height, sampleSize),
                    )
                }
        } ?: return null
        return frame to rotation
    }

    private fun MediaMetadataRetriever.extractInt(key: Int): Int? = extractMetadata(key)?.toIntOrNull()

    private fun noFrame(uri: Uri, cause: Throwable? = null) =
        FileNotFoundException("No frame can be read from the video at $uri").apply {
            if (cause != null) {
                initCause(cause)
            }
        }
}
