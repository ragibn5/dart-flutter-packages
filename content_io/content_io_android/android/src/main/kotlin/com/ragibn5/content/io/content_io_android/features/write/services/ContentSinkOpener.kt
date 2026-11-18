package com.ragibn5.content.io.content_io_android.features.write.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.os.ParcelFileDescriptor
import androidx.core.net.toUri
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import java.io.FileNotFoundException

/**
 * Content opened for writing.
 */
internal sealed interface OpenedContentSink {
    /**
     * A descriptor its provider doesn't watch, detached from its
     * [ParcelFileDescriptor]: whoever receives [fd] owns it and must close it.
     */
    data class Fd(
        /** The file descriptor. */
        val fd: Int,
    ) : OpenedContentSink

    /**
     * A descriptor its provider watches for how the write ends, kept as it is
     * so the provider can be told; see [ParcelFileDescriptor.canDetectErrors].
     */
    class ParcelFd(
        /** The open descriptor; whoever receives it must close it. */
        val descriptor: ParcelFileDescriptor,
    ) : OpenedContentSink
}

/**
 * Opens content for writing, as a descriptor.
 *
 * Note: A descriptor is handed over only when its provider doesn't watch it,
 * such as a plain file. Handing it over detaches it, which tells a watching
 * provider, such as one streaming the content through a pipe or uploading a
 * file once it's closed, that the write failed; such a descriptor is kept.
 */
internal class ContentSinkOpener(
    private val contentResolver: ContentResolver,
) {
    /**
     * Opens the content [request] points to, in its mode.
     *
     * @param request the content to open, and how.
     * @return the opened sink; the caller owns what it holds.
     * @throws ContentIoException with an [OpenWriteExceptionCodes] code;
     * [OpenWriteExceptionCodes.UNSUPPORTED_OPERATION] if the provider offers
     * only part of a file. Or
     * [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if the provider
     * opens nothing.
     */
    fun open(request: OpenWriteRequest): Result<OpenedContentSink> = runCatching {
        // Opened as an asset, not with openFileDescriptor, to see whether it's a
        // whole file: openFileDescriptor rejects part of a file only by message.
        val asset = guardOpen(request.uri) {
            contentResolver.openAssetFileDescriptor(request.uri.toUri(), request.mode.fileMode)
        } ?: throw ContentIoException(
            ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
            "The content's provider opened nothing for writing: ${request.uri}"
        )
        if (asset.declaredLength >= 0) {
            asset.close()
            throw ContentIoException(
                OpenWriteExceptionCodes.UNSUPPORTED_OPERATION,
                "The content's provider offers only part of a file, which can't be written: ${request.uri}"
            )
        }

        val descriptor = asset.parcelFileDescriptor
        return@runCatching if (descriptor.canDetectErrors()) {
            OpenedContentSink.ParcelFd(descriptor)
        } else {
            OpenedContentSink.Fd(descriptor.detachFd())
        }
    }

    /**
     * Runs [open], mapping its failures to [OpenWriteExceptionCodes].
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
                OpenWriteExceptionCodes.CONTENT_NOT_FOUND,
                e.message ?: "The requested content does not seem to exist",
                details = mapOf("uri" to uri),
                cause = e
            )
        } catch (e: SecurityException) {
            throw ContentIoException(
                OpenWriteExceptionCodes.PERMISSION_DENIED,
                e.message ?: "Not allowed to write the requested content",
                cause = e
            )
        } catch (e: UnsupportedOperationException) {
            throw ContentIoException(
                OpenWriteExceptionCodes.UNSUPPORTED_OPERATION,
                e.message ?: "The content's provider can't write it in this mode",
                cause = e
            )
        } catch (e: IllegalArgumentException) {
            // A document provider reports a document missing from its tree this
            // way, naming the FileNotFoundException only in the message.
            if (e.message?.contains(FileNotFoundException::class.java.name) == true) {
                throw ContentIoException(
                    OpenWriteExceptionCodes.CONTENT_NOT_FOUND,
                    "The requested content does not seem to exist",
                    details = mapOf("uri" to uri),
                    cause = e
                )
            }
            throw ContentIoException(
                OpenWriteExceptionCodes.INVALID_REQUEST,
                e.message ?: "The uri is not a valid content uri",
                cause = e
            )
        }
    }
}
