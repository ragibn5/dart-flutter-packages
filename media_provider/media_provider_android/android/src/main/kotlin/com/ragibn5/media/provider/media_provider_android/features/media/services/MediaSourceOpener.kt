package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.graphics.Point
import android.os.Bundle
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import java.io.FileNotFoundException
import java.io.InputStream

/**
 * A media item opened for reading.
 */
internal sealed interface OpenedMediaSource {
    /**
     * A file descriptor, detached from its [android.os.ParcelFileDescriptor]:
     * whoever receives [fd] owns it and must close it.
     */
    data class Descriptor(
        /** The file descriptor. */
        val fd: Int,
        /** The offset of the item's first byte in the descriptor. */
        val offset: Long,
        /** The size of the item in bytes, or `null` if unknown. */
        val sizeInBytes: Long?,
        /** Whether the descriptor is a regular file, readable at an offset. */
        val isSeekable: Boolean,
    ) : OpenedMediaSource

    /**
     * A stream, for an item that can't be opened as a descriptor.
     */
    class Stream(
        /** The open stream; whoever receives it must close it. */
        val stream: InputStream,
    ) : OpenedMediaSource
}

/**
 * Opens media items for reading: as a descriptor when possible, otherwise as
 * a stream.
 */
internal class MediaSourceOpener(
    private val contentResolver: ContentResolver,
) {
    /**
     * Opens the item [request] points to.
     *
     * @param request the item to open.
     * @return the opened source; the caller owns what it holds.
     * @throws MediaProviderException with an [OpenMediaReadExceptionCodes]
     * code, or [MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if the
     * provider isn't responding.
     */
    fun open(request: OpenMediaReadRequest): Result<OpenedMediaSource> = runCatching {
        checkPermission()

        val uri = request.contentUri.toUri()
        val descriptor = guardOpen(request.contentUri) {
            contentResolver.openAssetFileDescriptor(uri, "r")
        }
        if (descriptor != null) {
            return@runCatching buildDescriptorSource(descriptor)
        }

        val stream = guardOpen(request.contentUri) { contentResolver.openInputStream(uri) }
            ?: throw MediaProviderException(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The media provider is not responding, we probably need a device restart"
            )
        return@runCatching OpenedMediaSource.Stream(stream)
    }

    /**
     * Opens the thumbnail of the item [request] points to, the way
     * `ContentResolver.loadThumbnail` does, without decoding it.
     *
     * @param request the item and the size to request its thumbnail at.
     * @return the thumbnail as a detached descriptor; the caller owns it.
     * @throws MediaProviderException with an [OpenMediaReadExceptionCodes]
     * code; [OpenMediaReadExceptionCodes.UNSUPPORTED_OPERATION] if the provider
     * returns no thumbnail.
     *
     * Note: Only the thumbnail's bytes are opened, never the original item's.
     */
    fun openThumbnail(request: OpenThumbnailReadRequest): Result<OpenedMediaSource.Descriptor> =
        runCatching {
            checkPermission()

            val options = Bundle().apply {
                putParcelable(
                    ContentResolver.EXTRA_SIZE,
                    Point(request.size.width, request.size.height)
                )
            }
            val descriptor = guardOpen(request.contentUri) {
                contentResolver.openTypedAssetFileDescriptor(
                    request.contentUri.toUri(),
                    "image/*",
                    options
                )
            } ?: throw MediaProviderException(
                OpenMediaReadExceptionCodes.UNSUPPORTED_OPERATION,
                "The media provider returned no thumbnail for the requested item"
            )
            return@runCatching buildDescriptorSource(descriptor)
        }

    /**
     * Builds an [OpenedMediaSource.Descriptor] from [descriptor], detaching its
     * file descriptor.
     *
     * @param descriptor the opened item; closed if it can't be inspected.
     * @return the detached file descriptor, with the item's offset, size and
     * whether it's seekable.
     * @throws MediaProviderException if the descriptor can't be inspected.
     *
     * Note: Detaches last, so a failure before that leaves nothing to leak.
     * After it, the caller owns the file descriptor and must close it.
     */
    private fun buildDescriptorSource(descriptor: AssetFileDescriptor): OpenedMediaSource.Descriptor {
        val stat = try {
            Os.fstat(descriptor.fileDescriptor)
        } catch (e: ErrnoException) {
            descriptor.close()
            throw MediaProviderException(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "Failed to inspect the media item's descriptor",
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
        return OpenedMediaSource.Descriptor(
            fd = fd,
            offset = descriptor.startOffset,
            sizeInBytes = sizeInBytes,
            isSeekable = isSeekable,
        )
    }

    /**
     * Runs [open], mapping its failures to [OpenMediaReadExceptionCodes].
     *
     * @param contentUri the item being opened, for the error details.
     * @param open the call that opens the item.
     * @return what [open] returns.
     * @throws MediaProviderException if [open] fails.
     */
    private fun <T> guardOpen(contentUri: String, open: () -> T): T {
        try {
            return open()
        } catch (e: FileNotFoundException) {
            throw MediaProviderException(
                OpenMediaReadExceptionCodes.MEDIA_NOT_FOUND,
                "The requested media item does not seem to exist",
                details = mapOf("uri" to contentUri),
                cause = e
            )
        } catch (e: SecurityException) {
            throw MediaProviderException(
                OpenMediaReadExceptionCodes.PERMISSION_DENIED,
                e.message ?: "Not allowed to read the requested media item",
                cause = e
            )
        } catch (e: IllegalArgumentException) {
            throw MediaProviderException(
                OpenMediaReadExceptionCodes.INVALID_REQUEST,
                e.message ?: "The content uri is not a valid media item uri",
                cause = e
            )
        }
    }

    /**
     * Checks the app may read media.
     *
     * @throws MediaProviderException with
     * [OpenMediaReadExceptionCodes.PERMISSION_DENIED] if it may not.
     */
    private fun checkPermission() {
        if (!isPermissionAvailable()) {
            throw MediaProviderException(
                OpenMediaReadExceptionCodes.PERMISSION_DENIED,
                "The required permissions for reading the media item is not granted"
            )
        }
    }

    private fun isPermissionAvailable(): Boolean {
        // TODO: Implement actual logic here
        return true
    }
}
