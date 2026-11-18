package com.ragibn5.content.io.content_io_android.testing

import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteReply
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteService

/** A [ContentWriteService] that answers with [reply], recording what it's asked. */
internal class FakeContentWriteService(
    private val reply: OpenWriteReply = OpenWriteReply.Channel("session-1"),
) : ContentWriteService {
    /** Thrown by [writeToSession], [closeWriteSession] and [abortWriteSession], when set. */
    var error: Exception? = null

    val openedRequests = mutableListOf<OpenWriteRequest>()
    val writes = mutableListOf<Pair<String, List<Byte>>>()
    val closedSessionIds = mutableListOf<String>()
    val abortedSessionIds = mutableListOf<String>()

    override suspend fun openWrite(request: OpenWriteRequest): OpenWriteReply {
        openedRequests += request
        return reply
    }

    override fun writeToSession(sessionId: String, bytes: ByteArray) {
        error?.let { throw it }
        writes += sessionId to bytes.toList()
    }

    override fun closeWriteSession(sessionId: String) {
        error?.let { throw it }
        closedSessionIds += sessionId
    }

    override fun abortWriteSession(sessionId: String) {
        error?.let { throw it }
        abortedSessionIds += sessionId
    }

    override fun abortAllWriteSessions() = Unit
}
