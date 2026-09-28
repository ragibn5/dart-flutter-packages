package com.ragibn5.media.provider.media_provider_android

import io.flutter.plugin.common.MethodChannel

/**
 * What a [MethodChannel.Result] was told, captured for assertions.
 *
 * `MethodChannel.Result` is an interface, so recording it needs no framework.
 */
internal sealed interface MethodChannelReply {
    data class Success(val value: Any?) : MethodChannelReply
    data class Error(
        val code: String,
        val message: String?,
        val details: Any?,
    ) : MethodChannelReply

    data object NotImplemented : MethodChannelReply
}

/**
 * A [MethodChannel.Result] that records the reply it was given.
 *
 * Flutter permits exactly one terminal call per invocation, so a second call
 * overwrites the first.
 */
internal class RecordingMethodChannelResult : MethodChannel.Result {
    var reply: MethodChannelReply? = null
        private set

    override fun success(result: Any?) {
        reply = MethodChannelReply.Success(result)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        reply = MethodChannelReply.Error(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {
        reply = MethodChannelReply.NotImplemented
    }
}
