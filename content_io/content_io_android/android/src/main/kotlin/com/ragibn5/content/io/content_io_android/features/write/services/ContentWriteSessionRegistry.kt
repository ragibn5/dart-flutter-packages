package com.ragibn5.content.io.content_io_android.features.write.services

import com.ragibn5.content.io.content_io_android.features.write.io.session.ContentWriteSession
import java.util.concurrent.ConcurrentHashMap

internal class ContentWriteSessionRegistry {
    // Concurrent: the background write channel reads it off the main thread.
    private val _sessionMap: MutableMap<String, ContentWriteSession> = ConcurrentHashMap()
    val sessionMap: Map<String, ContentWriteSession>
        get() = _sessionMap

    fun addSession(session: ContentWriteSession) {
        _sessionMap[session.sessionId] = session
    }

    fun removeSession(sessionId: String): ContentWriteSession? {
        return _sessionMap.remove(sessionId)
    }

    /**
     * Removes every session.
     *
     * @return the removed sessions, for the caller to close.
     */
    fun removeAllSessions(): List<ContentWriteSession> {
        return _sessionMap.keys.mapNotNull { _sessionMap.remove(it) }
    }
}
