package com.ragibn5.media.provider.media_provider_android

import io.flutter.plugin.common.MethodCall

internal interface MethodCallRequestHandler {
    /**
     * Name of the channel method this handler serves.
     */
    val method: String

    /**
     * Handles [call] and returns the value to reply with.
     *
     * Called on the main thread; blocking work must be moved off it.
     * Throws [com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException]
     * to reply with a specific error.
     */
    suspend fun handle(call: MethodCall): Any?
}