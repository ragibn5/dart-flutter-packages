package com.ragibn5.media.provider.media_provider_android.handlers

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Routes each method call to the [MethodCallRequestHandler] registered for it.
 *
 * Handlers run as coroutines in [scope], and their outcome is replied on the
 * main thread. Calls with no registered handler are answered with `notImplemented`.
 *
 * Call [dispose] when the channel is torn down to cancel in-flight calls.
 */
internal class MethodCallDispatcher(
    handlers: List<MethodCallRequestHandler>,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate),
) : MethodCallHandler {
    companion object {
        const val UNEXPECTED_ERROR_CODE = "unexpected_error"
    }

    private val handlersByMethod: Map<String, MethodCallRequestHandler> =
        handlers.associateBy { it.method }

    init {
        require(handlersByMethod.size == handlers.size) {
            "Multiple handlers registered for the same method: " +
                    handlers.groupBy { it.method }.filterValues { it.size > 1 }.keys
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val handler = handlersByMethod[call.method] ?: return result.notImplemented()
        scope.launch {
            val reply = try {
                handler.handle(call)
            } catch (e: CancellationException) {
                throw e
            } catch (e: MethodCallException) {
                return@launch result.error(e.code, e.message, e.details)
            } catch (e: Exception) {
                return@launch result.error(UNEXPECTED_ERROR_CODE, e.message, null)
            }
            result.success(reply)
        }
    }

    /**
     * Cancels all in-flight calls.
     *
     * The dispatcher must not be used afterwards.
     */
    fun dispose() {
        scope.cancel()
    }
}
