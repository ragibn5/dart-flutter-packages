package com.ragibn5.content.io.content_io_android.features.write.handlers

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.WriteExceptionCodes
import com.ragibn5.content.io.content_io_android.testing.FakeContentWriteService
import com.ragibn5.content.io.content_io_android.testing.RecordingResult
import com.ragibn5.content.io.content_io_android.testing.Reply
import io.flutter.plugin.common.MethodCall
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

internal class BackgroundWriteCallHandlerTest {
    private val service = FakeContentWriteService()
    private val handler = BackgroundWriteCallHandler(service)
    private val result = RecordingResult()

    private fun call(method: String, arguments: Any?) = handler.onMethodCall(MethodCall(method, arguments), result)

    @Test
    fun onMethodCallShouldReplyNotImplementedIfMethodIsUnknown() {
        call("openWriteSession", null)

        assertEquals(Reply.NotImplemented, result.reply)
    }

    @Test
    fun onMethodCallShouldWriteBytesToSessionIfMethodIsWriteToSession() {
        call("writeToSession", mapOf("sessionId" to "session-1", "bytes" to byteArrayOf(1, 2)))

        assertEquals(listOf("session-1" to listOf<Byte>(1, 2)), service.writes)
        assertEquals(Reply.Success(null), result.reply)
    }

    @Test
    fun onMethodCallShouldReplyInvalidRequestIfBytesAreMissing() {
        call("writeToSession", mapOf("sessionId" to "session-1"))

        assertEquals(WriteExceptionCodes.INVALID_REQUEST, assertIs<Reply.Error>(result.reply).code)
    }

    @Test
    fun onMethodCallShouldCloseSessionIfMethodIsCloseWriteSession() {
        call("closeWriteSession", mapOf("sessionId" to "session-1"))

        assertEquals(listOf("session-1"), service.closedSessionIds)
        assertEquals(Reply.Success(null), result.reply)
    }

    @Test
    fun onMethodCallShouldAbortSessionIfMethodIsAbortWriteSession() {
        call("abortWriteSession", mapOf("sessionId" to "session-1"))

        assertEquals(listOf("session-1"), service.abortedSessionIds)
    }

    @Test
    fun onMethodCallShouldReplyInvalidRequestIfSessionIdIsMissing() {
        call("closeWriteSession", emptyMap<String, Any>())

        assertEquals(WriteExceptionCodes.INVALID_REQUEST, assertIs<Reply.Error>(result.reply).code)
    }

    @Test
    fun onMethodCallShouldReplyErrorOfProviderExceptionIfServiceFails() {
        service.error = ContentIoException(WriteExceptionCodes.NOT_ENOUGH_SPACE, "Full", details = "d")

        call("closeWriteSession", mapOf("sessionId" to "session-1"))

        assertEquals(Reply.Error(WriteExceptionCodes.NOT_ENOUGH_SPACE, "Full", "d"), result.reply)
    }

    @Test
    fun onMethodCallShouldReplyUnexpectedErrorIfServiceFailsOtherwise() {
        service.error = IllegalStateException("Broken")

        call("abortWriteSession", mapOf("sessionId" to "session-1"))

        assertEquals(
            Reply.Error(ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED, "Broken", null),
            result.reply,
        )
    }
}
