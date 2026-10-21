package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession

internal class MediaReadSessionRegistry {
    private val _sessionMap: MutableMap<String, MediaReadSession> = mutableMapOf()
    val sessionMap: Map<String, MediaReadSession>
        get() = _sessionMap

    fun addSession(session: MediaReadSession) {
        _sessionMap[session.sessionId] = session
    }
}