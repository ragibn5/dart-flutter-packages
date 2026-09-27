package com.ragibn5.media.provider.media_provider_android.handlers

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Routes each method call to the [MethodCallRequestHandler] registered for it.
 *
 * Calls with no registered handler are answered with `notImplemented`.
 */
class MethodCallDispatcher(handlers: List<MethodCallRequestHandler>) : MethodCallHandler {
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
        handler.handle(call, result)
    }
}
