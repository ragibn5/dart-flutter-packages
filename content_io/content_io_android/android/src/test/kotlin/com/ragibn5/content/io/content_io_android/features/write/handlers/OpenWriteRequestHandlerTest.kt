package com.ragibn5.content.io.content_io_android.features.write.handlers

import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteReply
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.models.WriteMode
import com.ragibn5.content.io.content_io_android.testing.FakeContentWriteService
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenWriteRequestHandlerTest {
    private val reply = OpenWriteReply.Descriptor(fd = 42)
    private val service = FakeContentWriteService(reply = reply)
    private val handler = OpenWriteRequestHandler(service)

    @Test
    fun methodShouldBeOpenWriteSession() {
        assertEquals("openWriteSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertContentIoError(OpenWriteExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openWriteSession", null))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnReplyAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall("openWriteSession", """{"uri":"content://a/document/1","mode":"append"}"""),
        )

        assertEquals(listOf(OpenWriteRequest("content://a/document/1", WriteMode.APPEND)), service.openedRequests)
        assertEquals(reply, Json.decodeFromString<OpenWriteReply>(encoded as String))
    }
}
