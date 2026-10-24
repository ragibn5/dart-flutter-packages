package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadRequestDecoder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.utils.Laps
import com.ragibn5.media.provider.media_provider_android.utils.logMark
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Experimental: serves `readFromSession` on a channel bound to a background
 * task queue.
 *
 * [onMethodCall] already runs off the main thread, so the read happens and the
 * reply is sent right there, with no coroutine dispatch and no thread hops.
 */
internal class BackgroundReadCallHandler(
    private val mediaStoreService: MediaStoreService,
    private val mediaReadRequestDecoder: MediaReadRequestDecoder = MediaReadRequestDecoder(),
    private val commonErrorCodes: MediaProviderCommonExceptionCodes = MediaProviderCommonExceptionCodes,
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != METHOD) return result.notImplemented()

        logMark("[bg $METHOD] native received on ${Thread.currentThread().name}")
        val laps = Laps("[bg $METHOD] native")
        val reply = try {
            val request = parseRequest(call)
            laps.lap("decode request")
            mediaStoreService.readFromSessionBlocking(request)
                .also { laps.lap("read") }
        } catch (e: MediaProviderException) {
            return result.error(e.code, e.message, e.details)
        } catch (e: Exception) {
            e.printStackTrace()
            return result.error(commonErrorCodes.ERROR_CODE_UNEXPECTED, e.message, null)
        }
        result.success(reply)
        laps.lap("result.success (encode + send)")
        logMark("[bg $METHOD] native replied")
    }

    private fun parseRequest(call: MethodCall): MediaReadRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = OpenMediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass a valid JSON representation of ${MediaReadRequest::class.java.simpleName}"
            )
        return mediaReadRequestDecoder.decode(argument).getOrThrow()
    }

    companion object {
        const val METHOD = "readFromSession"
    }
}
