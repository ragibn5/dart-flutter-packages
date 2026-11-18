package com.ragibn5.content.io.content_io_android.testing

import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService

/** A [ContentReadService] that answers with [reply] and [bytes], recording what it's asked. */
internal class FakeContentReadService(
    private val reply: OpenReadReply = OpenReadReply.Channel("session-1", null, false),
    private val bytes: ByteArray = ByteArray(0),
) : ContentReadService {
    /** Thrown by [readFromSession] instead of answering, when set. */
    var readError: Exception? = null

    val openedRequests = mutableListOf<Any>()
    val readRequests = mutableListOf<ReadRequest>()
    val closedSessionIds = mutableListOf<String>()

    override suspend fun openRead(request: OpenReadRequest): OpenReadReply {
        openedRequests += request
        return reply
    }

    override suspend fun openThumbnail(request: OpenThumbnailReadRequest): OpenReadReply {
        openedRequests += request
        return reply
    }

    override fun readFromSession(request: ReadRequest): ByteArray {
        readRequests += request
        readError?.let { throw it }
        return bytes
    }

    override suspend fun closeReadSession(sessionId: String) {
        closedSessionIds += sessionId
    }

    override fun closeAllReadSessions() = Unit
}
