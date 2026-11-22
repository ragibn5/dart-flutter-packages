package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.graphics.Point
import android.net.Uri
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import androidx.core.net.toUri
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import java.io.ByteArrayInputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream

/**
 * Content opened for reading.
 */
internal sealed interface OpenedForRead {
    /**
     * A file descriptor, detached from its [android.os.ParcelFileDescriptor]:
     * whoever receives [fd] owns it and must close it.
     */
    data class DetachedFd(
        /** The file descriptor. */
        val fd: Int,
        /** The offset of the content's first byte in the descriptor. */
        val offset: Long,
        /** The size of the content in bytes, or `null` if unknown. */
        val sizeInBytes: Long?,
        /** Whether the descriptor is a regular file, readable at an offset. */
        val isSeekable: Boolean,
    ) : OpenedForRead

    /**
     * A descriptor its provider watches for how the read ends, kept as it is
     * so the provider can be told; see [ParcelFileDescriptor.canDetectErrors].
     */
    class WatchedAssetFd(
        /** The open descriptor; whoever receives it must close it. */
        val descriptor: AssetFileDescriptor,
    ) : OpenedForRead

    /**
     * A stream, for content that can't be opened as a descriptor.
     */
    class FallbackStream(
        /** The open stream; whoever receives it must close it. */
        val stream: InputStream,
    ) : OpenedForRead
}

/**
 * Opens content for reading: as a descriptor when possible, otherwise as a
 * stream.
 *
 * Note: A descriptor is handed over only when its provider doesn't watch it.
 * Handing it over detaches it, which tells a watching provider the read
 * failed; such a descriptor is kept instead.
 */
internal class ContentReadOpener(
    private val contentResolver: ContentResolver,
    private val imageThumbnails: ImageThumbnails,
    private val videoFrameThumbnails: VideoFrameThumbnails,
) {
    /**
     * Opens the content [request] points to.
     *
     * @param request the content to open.
     * @return the opened content; the caller owns what it holds.
     * @throws ContentIoException with an [OpenReadExceptionCodes]
     * code, or [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if the
     * provider isn't responding.
     */
    fun open(request: OpenReadRequest): Result<OpenedForRead> = runCatching {
        val uri = request.uri.toUri()
        val descriptor = guardOpen(request.uri) {
            contentResolver.openAssetFileDescriptor(uri, "r")
        }
        if (descriptor != null) {
            return@runCatching handOverOrKeep(descriptor)
        }

        val stream = guardOpen(request.uri) { contentResolver.openInputStream(uri) }
            ?: throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The content provider is not responding, we probably need a device restart"
            )
        return@runCatching OpenedForRead.FallbackStream(stream)
    }

    /**
     * Opens the content [request] points to as a stream, for reading on this side.
     *
     * @param request the content to open.
     * @return the open stream; the caller must close it.
     * @throws ContentIoException with an [OpenReadExceptionCodes]
     * code, or [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if the
     * provider isn't responding.
     *
     * Note: A descriptor is read through a stream that keeps to the content's
     * own section of it, and closing the stream closes the descriptor.
     */
    fun openStream(request: OpenReadRequest): Result<InputStream> = runCatching {
        val uri = request.uri.toUri()
        val descriptor = guardOpen(request.uri) {
            contentResolver.openAssetFileDescriptor(uri, "r")
        }
        if (descriptor != null) {
            return@runCatching try {
                descriptor.createInputStream()
            } catch (e: IOException) {
                descriptor.close()
                throw ContentIoException(
                    ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                    "Failed to read the content's descriptor",
                    cause = e
                )
            }
        }

        return@runCatching guardOpen(request.uri) { contentResolver.openInputStream(uri) }
            ?: throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The content provider is not responding, we probably need a device restart"
            )
    }

    /**
     * Opens the thumbnail of the content [request] points to.
     *
     * @param request the content, the size to request its thumbnail at, and how to fit it.
     * @return the opened thumbnail; the caller owns what it holds.
     * @throws ContentIoException with an [OpenReadExceptionCodes]
     * code; [OpenReadExceptionCodes.CONTENT_NOT_FOUND] if the content has
     * no thumbnail, or [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED]
     * if the provider isn't responding.
     *
     * Note: The algorithm, the same as [ContentResolver.loadThumbnail]'s, with a fast path
     * and fallbacks:
     * 1. The content's provider is asked for a thumbnail at the requested size.
     * 2. If it gives an image, its header alone is read. If the image fits the request by
     *    [ThumbnailRules], it's handed over untouched; otherwise it's decoded scaled down
     *    and rotated upright.
     * 3. If it gives nothing, or something that isn't an image (a video handed back as it
     *    is), the thumbnail is made from the content itself: an image is decoded the same
     *    way, a video, or content of unknown type, gives a frame.
     * 4. Otherwise the content has no thumbnail.
     *
     * Only a refusal for permissions stops it early: that's never hidden by a fallback.
     */
    fun openThumbnail(request: OpenThumbnailReadRequest): Result<OpenedForRead> =
        runCatching {
            val uri = request.uri.toUri()
            val descriptor = openProviderThumbnail(request, uri)
            if (descriptor != null) {
                val checked = guardOpen(request.uri) {
                    imageThumbnails.checkProviderThumbnail(descriptor, request)
                }
                when (checked) {
                    CheckedThumbnail.Unchanged -> return@runCatching handOverOrKeep(descriptor)
                    is CheckedThumbnail.Fitted ->
                        return@runCatching OpenedForRead.FallbackStream(ByteArrayInputStream(checked.bytes))
                    CheckedThumbnail.NotAnImage -> Unit
                }
            }

            val bytes = guardOpen(request.uri) { makeThumbnailFromContent(uri, request) }
            return@runCatching OpenedForRead.FallbackStream(ByteArrayInputStream(bytes))
        }

    /**
     * Asks the provider of [uri] for its thumbnail at [request]'s size.
     *
     * @return the thumbnail, or `null` if the provider has none.
     * @throws ContentIoException if the provider refuses, or isn't responding.
     */
    private fun openProviderThumbnail(
        request: OpenThumbnailReadRequest,
        uri: Uri,
    ): AssetFileDescriptor? {
        val options = Bundle().apply {
            putParcelable(
                ContentResolver.EXTRA_SIZE,
                Point(request.size.width, request.size.height)
            )
        }
        return try {
            guardOpen(request.uri) {
                contentResolver.openTypedAssetFileDescriptor(uri, "image/*", options)
            } ?: throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The content provider is not responding, we probably need a device restart"
            )
        } catch (e: ContentIoException) {
            if (e.code != OpenReadExceptionCodes.CONTENT_NOT_FOUND) {
                throw e
            }
            null
        } catch (e: UnsupportedOperationException) {
            // A document provider that makes no thumbnails may say so this way.
            null
        }
    }

    /**
     * Makes a thumbnail for [request] from the content at [uri] itself: by decoding an
     * image, or reading a frame of a video. Content of unknown type is tried as both.
     *
     * @throws FileNotFoundException if no thumbnail can be made from it.
     * @throws SecurityException if the app can't read [uri].
     */
    private fun makeThumbnailFromContent(uri: Uri, request: OpenThumbnailReadRequest): ByteArray {
        val type = contentResolver.getType(uri)
        return when {
            type == null -> try {
                imageThumbnails.makeFromImage(uri, request)
            } catch (e: FileNotFoundException) {
                videoFrameThumbnails.makeFromVideo(uri, request)
            }

            type.startsWith("image/") -> imageThumbnails.makeFromImage(uri, request)
            type.startsWith("video/") -> videoFrameThumbnails.makeFromVideo(uri, request)
            else -> throw FileNotFoundException("Content of type $type has no thumbnail")
        }
    }

    /**
     * Keeps [descriptor] if its provider watches it, otherwise builds a
     * descriptor to hand over.
     */
    private fun handOverOrKeep(descriptor: AssetFileDescriptor): OpenedForRead {
        return if (descriptor.parcelFileDescriptor.canDetectErrors()) {
            OpenedForRead.WatchedAssetFd(descriptor)
        } else {
            buildDetachedFd(descriptor)
        }
    }

    /**
     * Builds an [OpenedForRead.DetachedFd] from [descriptor], detaching its
     * file descriptor.
     *
     * @param descriptor the opened content; closed if it can't be inspected.
     * @return the detached file descriptor, with the content's offset, size and
     * whether it's seekable.
     * @throws ContentIoException if the descriptor can't be inspected.
     *
     * Note: Detaches last, so a failure before that leaves nothing to leak.
     * After it, the caller owns the file descriptor and must close it.
     */
    private fun buildDetachedFd(descriptor: AssetFileDescriptor): OpenedForRead.DetachedFd {
        val stat = try {
            Os.fstat(descriptor.fileDescriptor)
        } catch (e: ErrnoException) {
            descriptor.close()
            throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "Failed to inspect the content's descriptor",
                cause = e
            )
        }

        val isSeekable = OsConstants.S_ISREG(stat.st_mode)
        val sizeInBytes = when {
            descriptor.length != AssetFileDescriptor.UNKNOWN_LENGTH -> descriptor.length
            isSeekable -> stat.st_size - descriptor.startOffset
            else -> null
        }
        // Last: after this, the descriptor is no longer this side's to close.
        val fd = descriptor.parcelFileDescriptor.detachFd()
        return OpenedForRead.DetachedFd(
            fd = fd,
            offset = descriptor.startOffset,
            sizeInBytes = sizeInBytes,
            isSeekable = isSeekable,
        )
    }

    /**
     * Runs [open], mapping its failures to [OpenReadExceptionCodes].
     *
     * @param uri the content being opened, for the error details.
     * @param open the call that opens it.
     * @return what [open] returns.
     * @throws ContentIoException if [open] fails.
     */
    private fun <T> guardOpen(uri: String, open: () -> T): T {
        try {
            return open()
        } catch (e: FileNotFoundException) {
            throw ContentIoException(
                OpenReadExceptionCodes.CONTENT_NOT_FOUND,
                "The requested content does not seem to exist",
                details = mapOf("uri" to uri),
                cause = e
            )
        } catch (e: SecurityException) {
            throw ContentIoException(
                OpenReadExceptionCodes.PERMISSION_DENIED,
                e.message ?: "Not allowed to read the requested content",
                cause = e
            )
        } catch (e: IllegalArgumentException) {
            // A document provider reports a document missing from its tree this
            // way, naming the FileNotFoundException only in the message.
            if (e.message?.contains(FileNotFoundException::class.java.name) == true) {
                throw ContentIoException(
                    OpenReadExceptionCodes.CONTENT_NOT_FOUND,
                    "The requested content does not seem to exist",
                    details = mapOf("uri" to uri),
                    cause = e
                )
            }
            throw ContentIoException(
                OpenReadExceptionCodes.INVALID_REQUEST,
                e.message ?: "The uri is not a valid content uri",
                cause = e
            )
        }
    }
}
