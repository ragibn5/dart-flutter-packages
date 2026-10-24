package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadRequestDecoder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Serves `readFromSession` on a channel bound to a background task queue.
 *
 * [onMethodCall] already runs off the main thread, so the read happens and the
 * reply is sent right there, with no coroutine dispatch and no thread hops.
 */
internal class BackgroundReadCallHandler(
    private val mediaReadService: MediaReadService,
    private val mediaReadRequestDecoder: MediaReadRequestDecoder = MediaReadRequestDecoder(),
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != METHOD) return result.notImplemented()

        val reply = try {
            mediaReadService.readFromSession(parseRequest(call))
        } catch (e: MediaProviderException) {
            return result.error(e.code, e.message, e.details)
        } catch (e: Exception) {
            e.printStackTrace()
            return result.error(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                e.message,
                null
            )
        }
        result.success(reply)
    }

    private fun parseRequest(call: MethodCall): MediaReadRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = MediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass a valid JSON representation of ${MediaReadRequest::class.java.simpleName}"
            )
        return mediaReadRequestDecoder.decode(argument).getOrThrow()
    }

    companion object {
        const val METHOD = "readFromSession"
    }
}
