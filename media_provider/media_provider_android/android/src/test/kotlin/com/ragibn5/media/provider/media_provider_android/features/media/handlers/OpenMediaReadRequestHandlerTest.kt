package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.testing.FakeMediaReadService
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenMediaReadRequestHandlerTest {
    private val reply = OpenMediaReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)
    private val service = FakeMediaReadService(reply = reply)
    private val handler = OpenMediaReadRequestHandler(service)

    @Test
    fun methodShouldBeOpenMediaReadSession() {
        assertEquals("openMediaReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openMediaReadSession", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openMediaReadSession", "{"))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnReplyAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall("openMediaReadSession", """{"contentUri":"content://media/external/images/media/1"}"""),
        )

        assertEquals(listOf<Any>(OpenMediaReadRequest("content://media/external/images/media/1")), service.openedRequests)
        assertEquals(reply, Json.decodeFromString<OpenMediaReadReply>(encoded as String))
    }
}
