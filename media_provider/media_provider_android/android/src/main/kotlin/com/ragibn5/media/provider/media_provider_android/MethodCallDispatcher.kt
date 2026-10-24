package com.ragibn5.media.provider.media_provider_android

import android.util.Log
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.utils.Laps
import com.ragibn5.media.provider.media_provider_android.utils.logMark
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

internal class MethodCallDispatcher(
    handlers: List<MethodCallRequestHandler>,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate),
    private val commonErrorCodes: MediaProviderCommonExceptionCodes = MediaProviderCommonExceptionCodes,
) : MethodChannel.MethodCallHandler {
    private val handlersByMethod: Map<String, MethodCallRequestHandler> =
        handlers.associateBy { it.method }

    init {
        require(handlersByMethod.size == handlers.size) {
            "Multiple handlers registered for the same method: " +
                    handlers.groupBy { it.method }.filterValues { it.size > 1 }.keys
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val handler = handlersByMethod[call.method] ?: return result.notImplemented()
        logMark("[${call.method}] native received")
        val laps = Laps("[${call.method}] native")
        scope.launch {
            laps.lap("coroutine dispatch")
            val reply = try {
                handler.handle(call).also { laps.lap("handle") }
            } catch (e: CancellationException) {
                throw e
            } catch (e: MediaProviderException) {
                return@launch result.error(e.code, e.message, e.details)
            } catch (e: Exception) {
                e.printStackTrace()
                return@launch result.error(
                    commonErrorCodes.ERROR_CODE_UNEXPECTED,
                    e.message,
                    null
                )
            }
            result.success(reply)
            laps.lap("result.success (encode + send)")
            logMark("[${call.method}] native replied")
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