package com.ragibn5.media.provider.media_provider_android.testing

import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadService

/** A [MediaReadService] that answers with [reply] and [bytes], recording what it's asked. */
internal class FakeMediaReadService(
    private val reply: OpenMediaReadReply = OpenMediaReadReply.Channel("session-1", null, false),
    private val bytes: ByteArray = ByteArray(0),
) : MediaReadService {
    /** Thrown by [readFromSession] instead of answering, when set. */
    var readError: Exception? = null

    val openedRequests = mutableListOf<Any>()
    val readRequests = mutableListOf<MediaReadRequest>()
    val closedSessionIds = mutableListOf<String>()

    override suspend fun openRead(request: OpenMediaReadRequest): OpenMediaReadReply {
        openedRequests += request
        return reply
    }

    override suspend fun openThumbnail(request: OpenThumbnailReadRequest): OpenMediaReadReply {
        openedRequests += request
        return reply
    }

    override fun readFromSession(request: MediaReadRequest): ByteArray {
        readRequests += request
        readError?.let { throw it }
        return bytes
    }

    override suspend fun closeReadSession(sessionId: String) {
        closedSessionIds += sessionId
    }

    override fun closeAllReadSessions() = Unit
}
