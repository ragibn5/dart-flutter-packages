package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaQueryExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.media.services.QuerySpecDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

internal class ReadMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val querySpecDecoder: QuerySpecDecoder = QuerySpecDecoder(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
    private val errorCodes: MediaQueryExceptionCodes = MediaQueryExceptionCodes,
) : MethodCallRequestHandler {
    override val method = "getMedia"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return withContext(dispatcher) {
            // Encoding a large library is CPU-bound.
            // So the whole reply is built off the main thread.
            // Querying from Default also avoids a hop back to main in between.
            Json.encodeToString(mediaStoreService.queryMedia(request))
        }
    }

    private fun parseRequest(call: MethodCall): QuerySpec {
        val argument = call.argument<String>(QUERY_ARGUMENT)
            ?: throw MediaProviderException(
                code = errorCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of $QuerySpec via the '$QUERY_ARGUMENT' argument"
            )
        return querySpecDecoder.decode(argument)
            .getOrThrow()
    }

    private companion object {
        private const val QUERY_ARGUMENT = "query"
    }
}