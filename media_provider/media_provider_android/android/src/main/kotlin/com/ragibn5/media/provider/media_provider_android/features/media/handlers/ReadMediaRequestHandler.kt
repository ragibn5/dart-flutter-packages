package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadOpenExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadRequestDecoder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

internal class ReadMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val readRequestDecoder: MediaReadRequestDecoder = MediaReadRequestDecoder(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
    private val errorCodes: MediaReadOpenExceptionCodes = MediaReadOpenExceptionCodes,
) : MethodCallRequestHandler {
    override val method = "openMediaForReading"


    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return withContext(dispatcher) {
            // Encoding a large library is CPU-bound.
            // So the whole reply is built off the main thread.
            // Querying from Default also avoids a hop back to main in between.
            Json.encodeToString(mediaStoreService.openMediaForReading(request))
        }
    }

    private fun parseRequest(call: MethodCall): MediaReadRequest {
        val argument = call.argument<String>(REQUEST_ARGUMENT)
            ?: throw MediaProviderException(
                code = errorCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of $MediaReadRequest via the '$REQUEST_ARGUMENT' argument"
            )
        return readRequestDecoder.decode(argument)
            .getOrThrow()
    }

    private companion object {
        private const val REQUEST_ARGUMENT = "request"
    }
}