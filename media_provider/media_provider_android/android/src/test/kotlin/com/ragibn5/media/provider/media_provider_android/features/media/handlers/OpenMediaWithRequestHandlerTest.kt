package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class OpenMediaWithRequestHandlerTest {
    private val opened = mutableListOf<OpenMediaWithRequest>()
    private val handler = OpenMediaWithRequestHandler({ opened += it })

    @Test
    fun methodShouldBeOpenMediaWith() {
        assertEquals("openMediaWith", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openMediaWith", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openMediaWith", "{"))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnNull() = runTest {
        val reply = handler.handle(
            MethodCall("openMediaWith", """{"contentUri":"content://media/external/images/media/1"}"""),
        )

        assertEquals(listOf(OpenMediaWithRequest("content://media/external/images/media/1")), opened)
        assertNull(reply)
    }
}
