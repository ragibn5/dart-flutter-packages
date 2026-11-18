package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.testing.FakeContentReadService
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class CloseReadSessionRequestHandlerTest {
    private val service = FakeContentReadService()
    private val handler = CloseReadSessionRequestHandler(service)

    @Test
    fun methodShouldBeCloseReadSession() {
        assertEquals("closeReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfSessionIdIsMissing() = runTest {
        assertContentIoError(ReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("closeReadSession", emptyMap<String, Any>()))
        }
    }

    @Test
    fun handleShouldCloseSessionAndReturnNull() = runTest {
        val reply = handler.handle(MethodCall("closeReadSession", mapOf("sessionId" to "session-1")))

        assertEquals(listOf("session-1"), service.closedSessionIds)
        assertNull(reply)
    }
}
