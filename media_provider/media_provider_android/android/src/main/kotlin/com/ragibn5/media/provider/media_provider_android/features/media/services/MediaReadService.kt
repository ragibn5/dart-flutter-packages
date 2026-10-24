package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.util.Log
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.io.session.StreamMediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.UUID

internal interface MediaReadService {
    /**
     * Opens the item [request] points to for reading.
     *
     * @return a [OpenMediaReadReply.Descriptor] when the item opens as a
     * descriptor, which is handed over and not kept here; otherwise a
     * [OpenMediaReadReply.Channel] for a session kept here, to read with
     * [readFromSession] and close with [closeReadSession].
     * @throws MediaProviderException with an open error code.
     */
    suspend fun openRead(request: OpenMediaReadRequest): OpenMediaReadReply

    /**
     * Reads from the session [MediaReadRequest.sessionId], on the calling
     * thread.
     *
     * @return the bytes read; fewer than requested only at the end of the item.
     * @throws MediaProviderException with a [MediaReadExceptionCodes] code.
     */
    fun readFromSession(request: MediaReadRequest): ByteArray

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

internal class MediaReadServiceImpl(
    private val mediaSourceOpener: MediaSourceOpener,
    private val sessionRegistry: MediaReadSessionRegistry = MediaReadSessionRegistry(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaReadService {
    override suspend fun openRead(request: OpenMediaReadRequest): OpenMediaReadReply {
        // Opening blocks, so keep it off the main thread.
        val source = withContext(dispatcher) {
            mediaSourceOpener.open(request).getOrThrow()
        }

        return when (source) {
            is OpenedMediaSource.Descriptor -> OpenMediaReadReply.Descriptor(
                fd = source.fd,
                offset = source.offset,
                sizeInBytes = source.sizeInBytes,
                isSeekable = source.isSeekable,
            )

            is OpenedMediaSource.Stream -> {
                val session = StreamMediaReadSession(UUID.randomUUID().toString(), source.stream)
                sessionRegistry.addSession(session)
                OpenMediaReadReply.Channel(
                    sessionId = session.sessionId,
                    sizeInBytes = session.sizeInBytes,
                    isSeekable = session.isSeekable,
                )
            }
        }
    }

    override fun readFromSession(request: MediaReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw MediaProviderException(
                MediaReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed",
                details = mapOf("sessionId" to request.sessionId)
            )

        try {
            return session.read(request.start, request.length)
        } catch (e: IOException) {
            throw MediaProviderException(
                MediaReadExceptionCodes.READ_ERROR,
                "Error while reading the media item",
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

    companion object {
        const val TAG = "MediaReadServiceImpl"
    }
}
