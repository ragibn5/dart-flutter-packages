package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.graphics.BitmapFactory
import android.media.ExifInterface
import android.media.MediaDataSource
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import java.io.BufferedInputStream
import java.io.ByteArrayInputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream

/**
 * What a provider's thumbnail turned out to be, once checked against a request.
 */
internal sealed interface CheckedThumbnail {
    /** Not an image, such as a video handed back as it is; the descriptor is closed. */
    data object NotAnImage : CheckedThumbnail

    /** Fits the request as it is; the descriptor is left open, to hand over. */
    data object Unchanged : CheckedThumbnail

    /** The thumbnail's bytes, fitted to the request; the descriptor is closed. */
    class Fitted(val bytes: ByteArray) : CheckedThumbnail
}

/**
 * Fits images to a thumbnail request, by [ThumbnailRules]: scaled down to close to the
 * requested size and rotated upright.
 */
internal class ImageThumbnails(private val contentResolver: ContentResolver) {
    /**
     * Checks the thumbnail a provider gave in [descriptor] against [request].
     *
     * @return [CheckedThumbnail.Unchanged] if it already fits, leaving [descriptor] open;
     * otherwise the fitted bytes, or [CheckedThumbnail.NotAnImage], closing it.
     * @throws FileNotFoundException if it's an image that can't be decoded.
     *
     * Note:
     * - The rotation is the provider's hint ([DocumentsContract.EXTRA_ORIENTATION]), or else
     *   the EXIF tag in the thumbnail's own bytes.
     * - A regular file is only peeked at by position. A pipe, or a descriptor its provider
     *   watches, is read whole, as it can't be handed over once read from.
     */
    fun checkProviderThumbnail(
        descriptor: AssetFileDescriptor,
        request: OpenThumbnailReadRequest,
    ): CheckedThumbnail {
        var isHandedOver = false
        try {
            val hint = descriptor.extras
                ?.takeIf { it.containsKey(DocumentsContract.EXTRA_ORIENTATION) }
                ?.getInt(DocumentsContract.EXTRA_ORIENTATION)

            val length = getPeekableLength(descriptor)
            if (length != null) {
                val open = {
                    PositionalInputStream(descriptor.fileDescriptor, descriptor.startOffset, length)
                }
                val bounds = readBounds(open) ?: return CheckedThumbnail.NotAnImage
                val rotation = ThumbnailRules.getRotation(
                    hint ?: readRotation(open) {
                        it.setDataSource(descriptor.fileDescriptor, descriptor.startOffset, length)
                    },
                    request,
                )
                val sampleSize = ThumbnailRules.getSampleSize(bounds.first, bounds.second, request)
                if (ThumbnailRules.isUnchanged(sampleSize, rotation)) {
                    isHandedOver = true
                    return CheckedThumbnail.Unchanged
                }
                return CheckedThumbnail.Fitted(fit(open, bounds, sampleSize, rotation))
            }

            val bytes = readImageBytes(descriptor) ?: return CheckedThumbnail.NotAnImage
            val open = { ByteArrayInputStream(bytes) }
            val bounds = readBounds(open) ?: return CheckedThumbnail.NotAnImage
            val rotation = ThumbnailRules.getRotation(
                hint ?: readRotation(open) { it.setDataSource(ByteArrayMediaDataSource(bytes)) },
                request,
            )
            val sampleSize = ThumbnailRules.getSampleSize(bounds.first, bounds.second, request)
            if (ThumbnailRules.isUnchanged(sampleSize, rotation)) {
                return CheckedThumbnail.Fitted(bytes)
            }
            return CheckedThumbnail.Fitted(fit(open, bounds, sampleSize, rotation))
        } finally {
            if (!isHandedOver) {
                descriptor.close()
            }
        }
    }

    /**
     * Makes a thumbnail for [request] from the image at [uri] itself.
     *
     * @throws FileNotFoundException if it isn't an image that can be decoded.
     * @throws SecurityException if the app can't read [uri].
     */
    fun makeFromImage(uri: Uri, request: OpenThumbnailReadRequest): ByteArray {
        val open = {
            contentResolver.openInputStream(uri)
                ?: throw FileNotFoundException("The content at $uri can't be opened")
        }
        val bounds = readBounds(open) ?: throw FileNotFoundException("The content at $uri isn't an image")
        val rotation = ThumbnailRules.getRotation(
            readRotation(open) { retriever ->
                val descriptor = contentResolver.openAssetFileDescriptor(uri, "r")
                    ?: throw FileNotFoundException("The content at $uri can't be opened")
                descriptor.use {
                    val length = if (it.length == AssetFileDescriptor.UNKNOWN_LENGTH) TO_THE_END else it.length
                    retriever.setDataSource(it.fileDescriptor, it.startOffset, length)
                }
            },
            request,
        )
        val sampleSize = ThumbnailRules.getSampleSize(bounds.first, bounds.second, request)
        return fit(open, bounds, sampleSize, rotation)
    }

    /**
     * The length of the content in [descriptor] if it's a regular file, which can be read
     * by position; `null` for a pipe, or a descriptor its provider watches.
     */
    private fun getPeekableLength(descriptor: AssetFileDescriptor): Long? {
        if (descriptor.parcelFileDescriptor.canDetectErrors()) {
            return null
        }
        val stat = try {
            Os.fstat(descriptor.fileDescriptor)
        } catch (e: ErrnoException) {
            throw IOException("Failed to inspect the thumbnail's descriptor", e)
        }
        if (!OsConstants.S_ISREG(stat.st_mode)) {
            return null
        }
        return if (descriptor.length != AssetFileDescriptor.UNKNOWN_LENGTH) {
            descriptor.length
        } else {
            stat.st_size - descriptor.startOffset
        }
    }

    /**
     * Reads all of [descriptor] if its first bytes are an image's.
     *
     * @return the bytes, or `null` if it isn't an image, without reading on.
     */
    private fun readImageBytes(descriptor: AssetFileDescriptor): ByteArray? {
        BufferedInputStream(descriptor.createInputStream(), HEADER_LIMIT).use { input ->
            input.mark(HEADER_LIMIT)
            val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeStream(NonClosingInputStream(input), null, options)
            if (options.outWidth <= 0 || options.outHeight <= 0) {
                return null
            }
            input.reset()
            return input.readBytes()
        }
    }

    /**
     * Reads the width and height of the image [open] opens, from its header only.
     *
     * @return `null` if it isn't an image.
     */
    private fun readBounds(open: () -> InputStream): Pair<Int, Int>? {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        open().use { BitmapFactory.decodeStream(it, null, options) }
        if (options.outWidth <= 0 || options.outHeight <= 0) {
            return null
        }
        return options.outWidth to options.outHeight
    }

    /**
     * The degrees the image [open] opens is meant to be rotated by: by its container if it's
     * HEIF, read through a retriever [setSource] points at it; otherwise by its EXIF tag.
     *
     * @return 0 if it isn't meant to be rotated, or that can't be read.
     */
    private fun readRotation(
        open: () -> InputStream,
        setSource: (MediaMetadataRetriever) -> Unit,
    ): Int {
        val header = open().use { it.readNBytesCompat(HEIF_HEADER_SIZE) }
        if (!ThumbnailRules.isHeif(header)) {
            return readExifRotation(open)
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            // HEIF images can't be decoded before Android 9 anyway.
            return 0
        }
        val retriever = MediaMetadataRetriever()
        return try {
            setSource(retriever)
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_IMAGE_ROTATION)
                ?.toIntOrNull() ?: 0
        } catch (e: SecurityException) {
            throw e
        } catch (e: RuntimeException) {
            0
        } catch (e: IOException) {
            0
        } finally {
            retriever.release()
        }
    }

    /** The degrees the EXIF tag in what [open] opens rotates by; 0 if it has none. */
    private fun readExifRotation(open: () -> InputStream): Int = try {
        open().use { input ->
            val orientation = ExifInterface(input).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL,
            )
            ThumbnailRules.getExifRotation(orientation)
        }
    } catch (e: IOException) {
        0
    }

    /**
     * Decodes the image [open] opens, of [bounds] in size, scaled down by [sampleSize] and
     * rotated by [rotation].
     *
     * @return the encoded result.
     * @throws FileNotFoundException if it can't be decoded.
     */
    private fun fit(
        open: () -> InputStream,
        bounds: Pair<Int, Int>,
        sampleSize: Int,
        rotation: Int,
    ): ByteArray {
        val options = BitmapFactory.Options().apply {
            inSampleSize = ThumbnailRules.getPowerOfTwoSampleSize(sampleSize)
        }
        val decoded = open().use { BitmapFactory.decodeStream(it, null, options) }
            ?: throw FileNotFoundException("The image can't be decoded")
        val scaled = ThumbnailBitmaps.scale(
            decoded,
            ThumbnailRules.getScaledLength(bounds.first, sampleSize),
            ThumbnailRules.getScaledLength(bounds.second, sampleSize),
        )
        return ThumbnailBitmaps.encode(ThumbnailBitmaps.rotate(scaled, rotation), canBeTransparent = true)
    }

    /** Leaves the wrapped stream open when closed, so it can be reset and read on. */
    private class NonClosingInputStream(private val input: InputStream) : InputStream() {
        override fun read(): Int = input.read()
        override fun read(buffer: ByteArray, offset: Int, count: Int): Int =
            input.read(buffer, offset, count)
        override fun close() = Unit
    }

    /** Serves [bytes] to a [MediaMetadataRetriever]. */
    private class ByteArrayMediaDataSource(private val bytes: ByteArray) : MediaDataSource() {
        override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
            if (position >= bytes.size) {
                return -1
            }
            val count = minOf(size.toLong(), bytes.size - position).toInt()
            System.arraycopy(bytes, position.toInt(), buffer, offset, count)
            return count
        }

        override fun getSize(): Long = bytes.size.toLong()

        override fun close() = Unit
    }

    /** Reads up to [count] bytes, fewer only at the end of the stream. */
    private fun InputStream.readNBytesCompat(count: Int): ByteArray {
        val buffer = ByteArray(count)
        var read = 0
        while (read < count) {
            val n = read(buffer, read, count - read)
            if (n <= 0) {
                break
            }
            read += n
        }
        return buffer.copyOf(read)
    }

    private companion object {
        /** How many bytes an image's header is looked for in. */
        private const val HEADER_LIMIT = 1024 * 1024

        /** The length that tells [MediaMetadataRetriever] to read to the end of a descriptor. */
        private const val TO_THE_END = 0x7ffffffffffffffL

        /** How many bytes tell a HEIF container: its size, 'ftyp' and its brand. */
        private const val HEIF_HEADER_SIZE = 12
    }
}
