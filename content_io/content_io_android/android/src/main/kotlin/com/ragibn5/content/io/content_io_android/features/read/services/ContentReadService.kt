package com.ragibn5.content.io.content_io_android.features.read.services

import android.util.Log
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.io.session.DescriptorContentReadSession
import com.ragibn5.content.io.content_io_android.features.read.io.session.StreamContentReadSession
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.UUID

internal interface ContentReadService {
    /**
     * Opens the content [request] points to for reading.
     *
     * @return a [OpenReadReply.Descriptor] when the content opens as a
     * descriptor, which is handed over and not kept here; otherwise a
     * [OpenReadReply.Channel] for a session kept here, to read with
     * [readFromSession] and close with [closeReadSession].
     * @throws ContentIoException with an open error code.
     */
    suspend fun openRead(request: OpenReadRequest): OpenReadReply

    /**
     * Opens the thumbnail of the content [request] points to for reading.
     *
     * @return a [OpenReadReply.Descriptor] for the thumbnail, which is
     * handed over and not kept here; or a [OpenReadReply.Channel] for a
     * session kept here, when the provider watches the descriptor.
     * @throws ContentIoException with an open error code.
     *
     * Note: Only the thumbnail's bytes are opened, never the original content's.
     */
    suspend fun openThumbnail(request: OpenThumbnailReadRequest): OpenReadReply

    /**
     * Reads from the session [ReadRequest.sessionId], on the calling
     * thread.
     *
     * @return the bytes read; fewer than requested only at the end of the content.
     * @throws ContentIoException with a [ReadExceptionCodes] code.
     */
    fun readFromSession(request: ReadRequest): ByteArray

    /**
     * Closes the session [sessionId] and releases everything it holds open.
     *
     * Does nothing if no such session is open.
     */
    suspend fun closeReadSession(sessionId: String)

    /**
     * Closes every open session, on the calling thread.
     *
     * Note: For when the plugin detaches, as the Dart side can no longer close
     * them.
     */
    fun closeAllReadSessions()
}

internal class ContentReadServiceImpl(
    private val contentSourceOpener: ContentSourceOpener,
    private val sessionRegistry: ContentReadSessionRegistry = ContentReadSessionRegistry(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : ContentReadService {
    override suspend fun openRead(request: OpenReadRequest): OpenReadReply {
        // Opening blocks, so keep it off the main thread.
        val source = withContext(dispatcher) {
            contentSourceOpener.open(request).getOrThrow()
        }

        return toReply(source)
    }

    override suspend fun openThumbnail(request: OpenThumbnailReadRequest): OpenReadReply {
        // Opening blocks, so keep it off the main thread.
        val source = withContext(dispatcher) {
            contentSourceOpener.openThumbnail(request).getOrThrow()
        }
        return toReply(source)
    }

    override fun readFromSession(request: ReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw ContentIoException(
                ReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed",
                details = mapOf("sessionId" to request.sessionId)
            )

        try {
            return session.read(request.start, request.length)
        } catch (e: IOException) {
            throw ContentIoException(
                ReadExceptionCodes.READ_ERROR,
                "Error while reading the content",
                cause = e
            )
        }
    }

    override suspend fun closeReadSession(sessionId: String) {
        val session = sessionRegistry.removeSession(sessionId) ?: return
        withContext(dispatcher) {
            runCatching { session.close() }
                .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
        }
    }

    override fun closeAllReadSessions() {
        sessionRegistry.removeAllSessions().forEach { session ->
            runCatching { session.close() }
                .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
        }
    }

    /**
     * The reply for [source]: a descriptor is handed over and not kept here;
     * anything else becomes a session kept here, read over the channel.
     */
    private fun toReply(source: OpenedContentSource): OpenReadReply {
        val session = when (source) {
            is OpenedContentSource.Fd -> return source.toReply()
            is OpenedContentSource.AssetFd -> DescriptorContentReadSession(newSessionId(), source.descriptor)
            is OpenedContentSource.Stream -> StreamContentReadSession(newSessionId(), source.stream)
        }
        sessionRegistry.addSession(session)
        return OpenReadReply.Channel(
            sessionId = session.sessionId,
            sizeInBytes = session.sizeInBytes,
            isSeekable = session.isSeekable,
        )
    }

    private fun newSessionId() = UUID.randomUUID().toString()

    /**
     * Describes this detached descriptor as an `openReadSession` reply.
     *
     * @return the reply that hands the descriptor over to the Dart side.
     */
    private fun OpenedContentSource.Fd.toReply() = OpenReadReply.Descriptor(
        fd = fd,
        offset = offset,
        sizeInBytes = sizeInBytes,
        isSeekable = isSeekable,
    )

    companion object {
        const val TAG = "ContentReadServiceImpl"
    }
}
