package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.io.session.StreamMediaReadSession
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue

internal class MediaReadSessionRegistryTest {
    private val registry = MediaReadSessionRegistry()

    private fun session(id: String) = StreamMediaReadSession(id, ByteArray(0).inputStream())

    @Test
    fun addSessionShouldKeepSessionUnderItsId() {
        val session = session("session-1")

        registry.addSession(session)

        assertSame(session, registry.sessionMap["session-1"])
    }

    @Test
    fun removeSessionShouldReturnAndForgetSessionIfItIsKept() {
        val session = session("session-1")
        registry.addSession(session)

        assertSame(session, registry.removeSession("session-1"))
        assertNull(registry.sessionMap["session-1"])
    }

    @Test
    fun removeSessionShouldReturnNullIfNoSessionHasId() {
        assertNull(registry.removeSession("session-1"))
    }

    @Test
    fun removeAllSessionsShouldReturnAndForgetEverySession() {
        val first = session("session-1")
        val second = session("session-2")
        registry.addSession(first)
        registry.addSession(second)

        assertEquals(setOf(first, second), registry.removeAllSessions().toSet())
        assertTrue(registry.sessionMap.isEmpty())
    }
}
