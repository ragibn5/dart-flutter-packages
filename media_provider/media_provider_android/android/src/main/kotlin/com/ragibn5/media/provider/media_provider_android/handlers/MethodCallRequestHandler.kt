package com.ragibn5.media.provider.media_provider_android.handlers

import io.flutter.plugin.common.MethodCall

/**
 * Handles a single method-channel method.
 *
 * Register implementations with [MethodCallDispatcher] to add channel methods
 * without changing the dispatch logic.
 */
internal interface MethodCallRequestHandler {
    /**
     * Name of the channel method this handler serves.
     */
    val method: String

    /**
     * Handles [call] and returns the value to reply with.
     *
     * Called on the main thread; blocking work must be moved off it. Throw
     * [MethodCallException] to reply with a specific error.
     */
    suspend fun handle(call: MethodCall): Any?
}

/**
 * Replied to Dart as a `PlatformException` with [code], [message] and [details].
 */
internal class MethodCallException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)
