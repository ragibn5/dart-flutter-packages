package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaErrorCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.media.services.QuerySpecDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

internal class GetMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val querySpecDecoder: QuerySpecDecoder = QuerySpecDecoder(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
    private val errorCodes: MediaErrorCodes = MediaErrorCodes,
) : MethodCallRequestHandler {
    override val method = "getMedia"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return withContext(dispatcher) {
            // Encoding a large library is CPU-bound.
            // So the whole reply is built off the main thread.
            // Querying from Default also avoids a hop back to main in between.
            Json.encodeToString(mediaStoreService.getMedia(request))
        }
    }

    private fun parseRequest(call: MethodCall): QuerySpec {
        val argument = call.argument<String>(QUERY_ARGUMENT)
            ?: throw MediaProviderException(
                code = errorCodes.INVALID_ARGUMENT,
                message = "You must provide a valid JSON representation of $QuerySpec via the '$QUERY_ARGUMENT' argument"
            )
        return querySpecDecoder.decode(argument)
            .getOrThrow()
    }

    private companion object {
        private const val QUERY_ARGUMENT = "query"
    }
}