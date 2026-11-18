package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.testing.FakeContentReadService
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenReadRequestHandlerTest {
    private val reply = OpenReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)
    private val service = FakeContentReadService(reply = reply)
    private val handler = OpenReadRequestHandler(service)

    @Test
    fun methodShouldBeOpenContentReadSession() {
        assertEquals("openReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openReadSession", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openReadSession", "{"))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnReplyAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall("openReadSession", """{"uri":"content://media/external/images/media/1"}"""),
        )

        assertEquals(listOf<Any>(OpenReadRequest("content://media/external/images/media/1")), service.openedRequests)
        assertEquals(reply, Json.decodeFromString<OpenReadReply>(encoded as String))
    }
}
