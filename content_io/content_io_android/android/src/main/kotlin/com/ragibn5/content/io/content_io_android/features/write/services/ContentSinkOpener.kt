package com.ragibn5.content.io.content_io_android.features.write.services

import android.content.ContentResolver
import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
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
     * A regular file's descriptor, detached from its [ParcelFileDescriptor]:
     * whoever receives [fd] owns it and must close it.
     */
    data class Descriptor(
        /** The file descriptor. */
        val fd: Int,
    ) : OpenedContentSink

    /**
     * A descriptor that isn't a regular file, such as a pipe, kept as it is so
     * the provider can be told how the write ended.
     */
    class Kept(
        /** The open descriptor; whoever receives it must close it. */
        val descriptor: ParcelFileDescriptor,
    ) : OpenedContentSink
}

/**
 * Opens content for writing: a regular file as a descriptor to hand over,
 * anything else as a descriptor to keep.
 */
internal class ContentSinkOpener(
    private val contentResolver: ContentResolver,
) {
    /**
     * Opens the content [request] points to, in its mode.
     *
     * @param request the content to open, and how.
     * @return the opened sink; the caller owns what it holds.
     * @throws ContentIoException with an [OpenWriteExceptionCodes] code, or
     * [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if the provider
     * opens nothing or its descriptor can't be inspected.
     */
    fun open(request: OpenWriteRequest): Result<OpenedContentSink> = runCatching {
        val descriptor = guardOpen(request.uri) {
            contentResolver.openFileDescriptor(request.uri.toUri(), request.mode.fileMode)
        } ?: throw ContentIoException(
            ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
            "The content's provider opened nothing for writing: ${request.uri}"
        )

        return@runCatching if (isRegularFile(descriptor)) {
            OpenedContentSink.Descriptor(descriptor.detachFd())
        } else {
            OpenedContentSink.Kept(descriptor)
        }
    }

    /**
     * Whether [descriptor] is a regular file.
     *
     * @throws ContentIoException with
     * [ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED] if it can't be
     * inspected; it's closed then.
     */
    private fun isRegularFile(descriptor: ParcelFileDescriptor): Boolean {
        try {
            return OsConstants.S_ISREG(Os.fstat(descriptor.fileDescriptor).st_mode)
        } catch (e: ErrnoException) {
            descriptor.close()
            throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "Failed to inspect the content's descriptor",
                cause = e
            )
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
            // Thrown by ContentResolver itself when the provider offers only part of a file.
            if (e.message == "Not a whole file") {
                throw ContentIoException(
                    OpenWriteExceptionCodes.UNSUPPORTED_OPERATION,
                    "The content's provider offers only part of a file, which can't be written",
                    cause = e
                )
            }
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
