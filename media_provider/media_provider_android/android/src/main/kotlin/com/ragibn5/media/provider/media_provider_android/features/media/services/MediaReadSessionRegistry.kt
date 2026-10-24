package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import java.util.concurrent.ConcurrentHashMap

internal class MediaReadSessionRegistry {
    // Concurrent: the background read channel reads it off the main thread.
    private val _sessionMap: MutableMap<String, MediaReadSession> = ConcurrentHashMap()
    val sessionMap: Map<String, MediaReadSession>
        get() = _sessionMap

    fun addSession(session: MediaReadSession) {
        _sessionMap[session.sessionId] = session
    }

    fun removeSession(sessionId: String): MediaReadSession? {
        return _sessionMap.remove(sessionId)
    }
}