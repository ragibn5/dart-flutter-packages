package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.testing.RecordingResult
import com.ragibn5.media.provider.media_provider_android.testing.Reply
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
internal class MethodCallDispatcherTest {
    private class Handler(override val method: String, private val answer: suspend () -> Any?) :
        MethodCallRequestHandler {
        override suspend fun handle(call: MethodCall): Any? = answer()
    }

    private val result = RecordingResult()

    private fun dispatcher(vararg handlers: MethodCallRequestHandler) =
        MethodCallDispatcher(handlers.toList(), CoroutineScope(UnconfinedTestDispatcher()))

    @Test
    fun shouldThrowIllegalArgumentExceptionIfHandlersServeSameMethod() {
        assertFailsWith<IllegalArgumentException> {
            dispatcher(Handler("queryMedia") { null }, Handler("queryMedia") { null })
        }
    }

    @Test
    fun onMethodCallShouldReplyNotImplementedIfNoHandlerServesMethod() {
        dispatcher(Handler("queryMedia") { null }).onMethodCall(MethodCall("getVolumes", null), result)

        assertEquals(Reply.NotImplemented, result.reply)
    }

    @Test
    fun onMethodCallShouldReplyWhatHandlerReturns() {
        dispatcher(Handler("getVolumes") { "[]" }).onMethodCall(MethodCall("getVolumes", null), result)

        assertEquals(Reply.Success("[]"), result.reply)
    }

    @Test
    fun onMethodCallShouldReplyErrorOfProviderExceptionIfHandlerThrowsIt() {
        val handler = Handler("getVolumes") {
            throw MediaProviderException("invalid_request", "Bad request", details = mapOf("uri" to "x"))
        }

        dispatcher(handler).onMethodCall(MethodCall("getVolumes", null), result)

        assertEquals(Reply.Error("invalid_request", "Bad request", mapOf("uri" to "x")), result.reply)
    }

    @Test
    fun onMethodCallShouldReplyUnexpectedIfHandlerThrowsOtherException() {
        val handler = Handler("getVolumes") { throw IllegalStateException("Broken") }

        dispatcher(handler).onMethodCall(MethodCall("getVolumes", null), result)

        assertEquals(
            Reply.Error(MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED, "Broken", null),
            result.reply,
        )
    }

    @Test
    fun disposeShouldCancelCallsInProgressWithoutReplying() {
        var wasCancelled = false
        val handler = Handler("getVolumes") {
            try {
                awaitCancellation()
            } finally {
                wasCancelled = true
            }
        }
        val dispatcher = dispatcher(handler)
        dispatcher.onMethodCall(MethodCall("getVolumes", null), result)

        dispatcher.dispose()

        assertTrue(wasCancelled)
        assertNull(result.reply)
    }
}
