package com.ragibn5.content.io.content_io_android.features.write.handlers

import android.util.Log
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.WriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Serves `writeToSession`, `closeWriteSession` and `abortWriteSession` on a
 * channel bound to a background task queue.
 *
 * [onMethodCall] already runs off the main thread, so the work happens and the
 * reply is sent right there. The queue runs calls in order, so a session is
 * closed only after every write sent before it.
 */
internal class BackgroundWriteCallHandler(
    private val contentWriteService: ContentWriteService,
) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                WRITE_METHOD -> contentWriteService.writeToSession(sessionId(call), bytes(call))
                CLOSE_METHOD -> contentWriteService.closeWriteSession(sessionId(call))
                ABORT_METHOD -> contentWriteService.abortWriteSession(sessionId(call))
                else -> return result.notImplemented()
            }
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
        result.success(null)
    }

    private fun sessionId(call: MethodCall): String {
        return call.argument<String>("sessionId")
            ?: throw ContentIoException(
                code = WriteExceptionCodes.INVALID_REQUEST,
                message = "You must pass the `sessionId` of the session"
            )
    }

    private fun bytes(call: MethodCall): ByteArray {
        return call.argument<ByteArray>("bytes")
            ?: throw ContentIoException(
                code = WriteExceptionCodes.INVALID_REQUEST,
                message = "You must pass the `bytes` to write"
            )
    }

    companion object {
        const val WRITE_METHOD = "writeToSession"
        const val CLOSE_METHOD = "closeWriteSession"
        const val ABORT_METHOD = "abortWriteSession"

        private const val TAG = "BackgroundWriteCallHandler"
    }
}
