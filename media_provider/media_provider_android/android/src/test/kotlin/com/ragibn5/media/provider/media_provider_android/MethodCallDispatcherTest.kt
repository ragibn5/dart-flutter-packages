package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertIs
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
internal class MethodCallDispatcherTest {
    private val result = RecordingMethodChannelResult()

    /**
     * A dispatcher whose replies are delivered eagerly, so assertions can run
     * straight after [MethodCallDispatcher.onMethodCall] returns.
     */
    private fun TestScope.dispatcher(
        vararg handlers: MethodCallRequestHandler,
    ): MethodCallDispatcher =
        MethodCallDispatcher(
            handlers.toList(),
            CoroutineScope(UnconfinedTestDispatcher(testScheduler))
        )

    private fun TestScope.dispatcherFor(vararg methods: String): MethodCallDispatcher =
        dispatcher(*methods.map { handlerFor(it) }.toTypedArray())

    private fun handlerFor(
        method: String,
        handle: suspend MethodCall.() -> Any? = { "handled:$method" },
    ): MethodCallRequestHandler = object : MethodCallRequestHandler {
        override val method = method

        override suspend fun handle(call: MethodCall): Any? = call.handle()
    }

    @Test
    fun `replies with the value returned by the matching handler`() = runTest {
        val dispatcher = dispatcherFor("getMedia", "getPhotos")

        dispatcher.onMethodCall(MethodCall("getPhotos", null), result)

        assertEquals(MethodChannelReply.Success("handled:getPhotos"), result.reply)
    }

    @Test
    fun `passes the call through to the handler untouched`() = runTest {
        var received: MethodCall? = null
        val dispatcher = dispatcher(handlerFor("getMedia") { received = this })

        val call = MethodCall("getMedia", mapOf("types" to listOf("photo")))
        dispatcher.onMethodCall(call, result)

        assertEquals(call, received)
    }

    @Test
    fun `replies not implemented for an unregistered method`() = runTest {
        val dispatcher = dispatcherFor("getMedia")

        dispatcher.onMethodCall(MethodCall("getPlatformVersion", null), result)

        assertEquals(MethodChannelReply.NotImplemented, result.reply)
    }

    @Test
    fun `does not reply twice when a method is unknown and then known`() = runTest {
        val dispatcher = dispatcherFor("getMedia")

        dispatcher.onMethodCall(MethodCall("nope", null), result)
        dispatcher.onMethodCall(MethodCall("getMedia", null), result)

        assertEquals(MethodChannelReply.Success("handled:getMedia"), result.reply)
    }

    @Test
    fun `replies with the code, message and details of a MethodCallException`() = runTest {
        val cause = IllegalStateException("root cause")
        val dispatcher = dispatcher(
            handlerFor("getMedia") {
                throw MethodCallException(
                    "invalid_argument",
                    "bad",
                    42,
                    cause
                )
            },
        )

        dispatcher.onMethodCall(MethodCall("getMedia", null), result)

        assertEquals(
            MethodChannelReply.Error("invalid_argument", "bad", 42),
            result.reply,
        )
    }

    @Test
    fun `replies with an unexpected error for any other exception`() = runTest {
        val dispatcher = dispatcher(handlerFor("getMedia") { throw RuntimeException("boom") })

        dispatcher.onMethodCall(MethodCall("getMedia", null), result)

        assertEquals(
            MethodChannelReply.Error(
                MethodCallDispatcher.UNEXPECTED_ERROR_CODE,
                "boom",
                null,
            ),
            result.reply,
        )
    }

    @Test
    fun `does not turn a CancellationException into an error reply`() = runTest {
        val dispatcher = dispatcher(
            handlerFor("getMedia") { throw CancellationException("cancelled") },
            handlerFor("getVideos"),
        )

        dispatcher.onMethodCall(MethodCall("getMedia", null), result)
        assertNull(result.reply, "a cancelled call must not be replied to")

        // The cancellation must not have taken the shared scope down with it.
        dispatcher.onMethodCall(MethodCall("getVideos", null), result)
        assertEquals(
            MethodChannelReply.Success("handled:getVideos"),
            result.reply,
        )
    }

    @Test
    fun `rejects two handlers registered for the same method`() {
        val error = assertFailsWith<IllegalArgumentException> {
            MethodCallDispatcher(
                listOf(handlerFor("getMedia"), handlerFor("getMedia")),
                // Rejected before any call is dispatched, so the scope is
                // irrelevant here; passed in only to keep the test off Main.
                CoroutineScope(Dispatchers.Unconfined),
            )
        }

        assertEquals(
            "Multiple handlers registered for the same method: [getMedia]",
            error.message,
        )
    }

    @Test
    fun `dispose drops calls that are still in flight`() = runTest {
        val dispatcher = dispatcher(handlerFor("getMedia") { awaitCancellation() })

        dispatcher.onMethodCall(MethodCall("getMedia", null), result)
        dispatcher.dispose()

        assertNull(result.reply, "an in-flight call must not be replied to after dispose")
    }

    @Test
    fun `dispose cancels the scope so later calls are dropped too`() = runTest {
        val dispatcher = dispatcherFor("getMedia")

        dispatcher.dispose()
        dispatcher.onMethodCall(MethodCall("getMedia", null), result)

        assertNull(result.reply)
    }

    @Test
    fun `replies null when a handler returns null`() = runTest {
        val dispatcher = dispatcher(handlerFor("getMedia") { null })

        dispatcher.onMethodCall(MethodCall("getMedia", null), result)

        val reply = assertIs<MethodChannelReply.Success>(result.reply)
        assertNull(reply.value)
    }
}
