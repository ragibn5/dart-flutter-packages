package com.ragibn5.content.io.content_io_android.features.write.services

import android.system.ErrnoException
import android.system.OsConstants
import android.util.Log
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.WriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.io.session.ContentWriteSession
import com.ragibn5.content.io.content_io_android.features.write.io.session.StreamContentWriteSession
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteReply
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.UUID

internal interface ContentWriteService {
    /**
     * Opens the content [request] points to for writing.
     *
     * @return a [OpenWriteReply.Descriptor] when the content opens as a
     * descriptor, which is handed over and not kept here; otherwise a
     * [OpenWriteReply.Channel] for a session kept here, to write with
     * [writeToSession], then finish with [closeWriteSession] or
     * [abortWriteSession].
     * @throws ContentIoException with an open error code.
     */
    suspend fun openWrite(request: OpenWriteRequest): OpenWriteReply

    /**
     * Writes [bytes] to the session [sessionId], on the calling thread.
     *
     * @throws ContentIoException with a [WriteExceptionCodes] code.
     */
    fun writeToSession(sessionId: String, bytes: ByteArray)

    /**
     * Syncs what the session [sessionId] wrote to the storage, then closes it,
     * on the calling thread.
     *
     * Note: The session is closed and removed even when syncing fails.
     *
     * @throws ContentIoException with a [WriteExceptionCodes] code; such as
     * [WriteExceptionCodes.NOT_ENOUGH_SPACE] when the volume filled up.
     */
    fun closeWriteSession(sessionId: String)

    /**
     * Closes the session [sessionId] without syncing, on the calling thread.
     *
     * Does nothing if no such session is open. What was written may or may
     * not be stored.
     */
    fun abortWriteSession(sessionId: String)

    /**
     * Aborts every open session, on the calling thread.
     *
     * Note: For when the plugin detaches, as the Dart side can no longer close
     * them.
     */
    fun abortAllWriteSessions()
}

internal class ContentWriteServiceImpl(
    private val contentSinkOpener: ContentSinkOpener,
    private val sessionRegistry: ContentWriteSessionRegistry = ContentWriteSessionRegistry(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : ContentWriteService {
    override suspend fun openWrite(request: OpenWriteRequest): OpenWriteReply {
        // Opening blocks, so keep it off the main thread.
        val sink = withContext(dispatcher) {
            contentSinkOpener.open(request).getOrThrow()
        }

        return when (sink) {
            is OpenedContentSink.Descriptor -> OpenWriteReply.Descriptor(fd = sink.fd)

            is OpenedContentSink.Stream -> {
                val session = StreamContentWriteSession(UUID.randomUUID().toString(), sink.stream)
                sessionRegistry.addSession(session)
                OpenWriteReply.Channel(sessionId = session.sessionId)
            }
        }
    }

    override fun writeToSession(sessionId: String, bytes: ByteArray) {
        val session = findSession(sessionId)
        try {
            session.write(bytes)
        } catch (e: IOException) {
            throw writeFailed(e)
        }
    }

    override fun closeWriteSession(sessionId: String) {
        val session = findSession(sessionId)
        sessionRegistry.removeSession(sessionId)
        try {
            session.use { it.sync() }
        } catch (e: IOException) {
            throw writeFailed(e)
        }
    }

    override fun abortWriteSession(sessionId: String) {
        sessionRegistry.removeSession(sessionId)?.let(::closeQuietly)
    }

    override fun abortAllWriteSessions() {
        sessionRegistry.removeAllSessions().forEach(::closeQuietly)
    }

    private fun findSession(sessionId: String): ContentWriteSession {
        return sessionRegistry.sessionMap[sessionId]
            ?: throw ContentIoException(
                WriteExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed",
                details = mapOf("sessionId" to sessionId)
            )
    }

    private fun closeQuietly(session: ContentWriteSession) {
        runCatching { session.close() }
            .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
    }

    /**
     * The failure to report for [cause]: [WriteExceptionCodes.NOT_ENOUGH_SPACE]
     * when the volume filled up, otherwise [WriteExceptionCodes.WRITE_ERROR].
     */
    private fun writeFailed(cause: IOException): ContentIoException {
        val isOutOfSpace = generateSequence<Throwable>(cause) { it.cause }.any {
            (it is ErrnoException && it.errno == OsConstants.ENOSPC) || it.message?.contains("ENOSPC") == true
        }
        return if (isOutOfSpace) {
            ContentIoException(
                WriteExceptionCodes.NOT_ENOUGH_SPACE,
                "The volume ran out of space while writing the content",
                cause = cause
            )
        } else {
            ContentIoException(
                WriteExceptionCodes.WRITE_ERROR,
                cause.message ?: "Error while writing the content",
                cause = cause
            )
        }
    }

    companion object {
        const val TAG = "ContentWriteServiceImpl"
    }
}
