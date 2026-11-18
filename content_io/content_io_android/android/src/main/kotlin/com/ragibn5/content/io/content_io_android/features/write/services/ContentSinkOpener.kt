package com.ragibn5.content.io.content_io_android.features.write.services

import android.content.ContentResolver
import androidx.core.net.toUri
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import java.io.FileNotFoundException
import java.io.OutputStream

/**
 * Content opened for writing.
 */
internal sealed interface OpenedContentSink {
    /**
     * A file descriptor, detached from its [android.os.ParcelFileDescriptor]:
     * whoever receives [fd] owns it and must close it.
     */
    data class Descriptor(
        /** The file descriptor. */
        val fd: Int,
    ) : OpenedContentSink

    /**
     * A stream, for content that can't be opened as a descriptor.
     */
    class Stream(
        /** The open stream; whoever receives it must close it. */
        val stream: OutputStream,
    ) : OpenedContentSink
}

/**
 * Opens content for writing: as a descriptor when possible, otherwise as a
 * stream.
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
     * isn't responding.
     */
    fun open(request: OpenWriteRequest): Result<OpenedContentSink> = runCatching {
        val uri = request.uri.toUri()
        val mode = request.mode.fileMode
        val descriptor = guardOpen(request.uri) { contentResolver.openFileDescriptor(uri, mode) }
        if (descriptor != null) {
            return@runCatching OpenedContentSink.Descriptor(descriptor.detachFd())
        }

        val stream = guardOpen(request.uri) { contentResolver.openOutputStream(uri, mode) }
            ?: throw ContentIoException(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The content provider is not responding, we probably need a device restart"
            )
        return@runCatching OpenedContentSink.Stream(stream)
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
