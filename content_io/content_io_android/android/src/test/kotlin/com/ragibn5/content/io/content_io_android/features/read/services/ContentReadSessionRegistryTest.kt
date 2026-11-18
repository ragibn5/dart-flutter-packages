package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.features.read.io.session.StreamContentReadSession
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue

internal class ContentReadSessionRegistryTest {
    private val registry = ContentReadSessionRegistry()

    private fun session(id: String) = StreamContentReadSession(id, ByteArray(0).inputStream())

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
