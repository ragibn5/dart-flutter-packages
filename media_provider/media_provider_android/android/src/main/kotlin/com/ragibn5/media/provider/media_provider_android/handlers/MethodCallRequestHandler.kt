package com.ragibn5.media.provider.media_provider_android.handlers

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Handles a single method-channel method.
 *
 * Register implementations with [MethodCallDispatcher] to add channel methods
 * without changing the dispatch logic.
 */
interface MethodCallRequestHandler {
    /**
     * Name of the channel method this handler serves.
     */
    val method: String

    /**
     * Handles [call] and replies through [result].
     */
    fun handle(call: MethodCall, result: Result)
}
