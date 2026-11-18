package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import com.ragibn5.content.io.content_io_android.testing.FakeContentReadService
import com.ragibn5.content.io.content_io_android.testing.RecordingResult
import com.ragibn5.content.io.content_io_android.testing.Reply
import io.flutter.plugin.common.MethodCall
import org.junit.jupiter.api.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertIs

internal class BackgroundReadCallHandlerTest {
    private val service = FakeContentReadService(bytes = byteArrayOf(1, 2, 3))
    private val handler = BackgroundReadCallHandler(service)
    private val result = RecordingResult()

    private fun read(arguments: Any? = """{"sessionId":"session-1","start":4,"length":3}""") =
        handler.onMethodCall(MethodCall("readFromSession", arguments), result)

    @Test
    fun onMethodCallShouldReplyNotImplementedIfMethodIsNotReadFromSession() {
        handler.onMethodCall(MethodCall("openReadSession", null), result)

        assertEquals(Reply.NotImplemented, result.reply)
    }

    @Test
    fun onMethodCallShouldReplyBytesReadFromDecodedRequest() {
        read()

        assertEquals(listOf(ReadRequest("session-1", start = 4, length = 3)), service.readRequests)
        assertContentEquals(byteArrayOf(1, 2, 3), assertIs<Reply.Success>(result.reply).value as ByteArray)
    }

    @Test
    fun onMethodCallShouldReplyInvalidRequestIfArgumentIsMissing() {
        read(arguments = null)

        assertEquals(ReadExceptionCodes.INVALID_REQUEST, assertIs<Reply.Error>(result.reply).code)
    }

    @Test
    fun onMethodCallShouldReplyErrorOfProviderExceptionIfReadFails() {
        service.readError = ContentIoException(
            ReadExceptionCodes.SESSION_NOT_FOUND,
            "No session",
            details = mapOf("sessionId" to "session-1"),
        )

        read()

        assertEquals(
            Reply.Error(ReadExceptionCodes.SESSION_NOT_FOUND, "No session", mapOf("sessionId" to "session-1")),
            result.reply,
        )
    }

    @Test
    fun onMethodCallShouldReplyUnexpectedIfReadFailsOtherwise() {
        service.readError = IllegalStateException("Broken")

        read()

        assertEquals(
            Reply.Error(ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED, "Broken", null),
            result.reply,
        )
    }
}
