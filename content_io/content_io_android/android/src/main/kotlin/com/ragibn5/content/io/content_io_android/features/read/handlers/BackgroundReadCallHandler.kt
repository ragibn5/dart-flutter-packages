package com.ragibn5.content.io.content_io_android.features.read.handlers

import android.util.Log
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.read.services.ReadRequestDecoder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Serves `readFromSession` on a channel bound to a background task queue.
 *
 * [onMethodCall] already runs off the main thread, so the read happens and the
 * reply is sent right there, with no coroutine dispatch and no thread hops.
 */
internal class BackgroundReadCallHandler(
    private val contentReadService: ContentReadService,
    private val requestDecoder: ReadRequestDecoder = ReadRequestDecoder(),
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != METHOD) return result.notImplemented()

        val reply = try {
            contentReadService.readFromSession(parseRequest(call))
        } catch (e: ContentIoException) {
            return result.error(e.code, e.message, e.details)
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error in ${call.method}", e)
            return result.error(
                ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                e.message,
                null
            )
        }
        result.success(reply)
    }

    private fun parseRequest(call: MethodCall): ReadRequest {
        val argument = call.arguments<String>()
            ?: throw ContentIoException(
                code = ReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass a valid JSON representation of ${ReadRequest::class.java.simpleName}"
            )
        return requestDecoder.decode(argument).getOrThrow()
    }

    companion object {
        const val METHOD = "readFromSession"

        private const val TAG = "BackgroundReadCallHandler"
    }
}
