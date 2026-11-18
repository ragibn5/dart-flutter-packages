package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.features.read.io.session.ContentReadSession
import java.util.concurrent.ConcurrentHashMap

internal class ContentReadSessionRegistry {
    // Concurrent: the background read channel reads it off the main thread.
    private val _sessionMap: MutableMap<String, ContentReadSession> = ConcurrentHashMap()
    val sessionMap: Map<String, ContentReadSession>
        get() = _sessionMap

    fun addSession(session: ContentReadSession) {
        _sessionMap[session.sessionId] = session
    }

    fun removeSession(sessionId: String): ContentReadSession? {
        return _sessionMap.remove(sessionId)
    }

    /**
     * Removes every session.
     *
     * @return the removed sessions, for the caller to close.
     */
    fun removeAllSessions(): List<ContentReadSession> {
        return _sessionMap.keys.mapNotNull { _sessionMap.remove(it) }
    }
}