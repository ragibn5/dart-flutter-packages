package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.testing.FakeMediaReadService
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class CloseReadSessionRequestHandlerTest {
    private val service = FakeMediaReadService()
    private val handler = CloseReadSessionRequestHandler(service)

    @Test
    fun methodShouldBeCloseReadSession() {
        assertEquals("closeReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfSessionIdIsMissing() = runTest {
        assertProviderError(MediaReadExceptionCodes.INVALID_REQUEST) {
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
