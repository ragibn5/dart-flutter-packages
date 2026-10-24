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

internal class QueryMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val querySpecDecoder: QuerySpecDecoder = QuerySpecDecoder(),
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
) : MethodCallRequestHandler {
    override val method = "queryMedia"

    override suspend fun handle(call: MethodCall): String = withContext(dispatcher) {
        val request = parseRequest(call)
        return@withContext Json.encodeToString(mediaStoreService.queryMedia(request))
    }

    private fun parseRequest(call: MethodCall): QuerySpec {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = MediaQueryExceptionCodes.INVALID_REQUEST,
                message = "You must pass a valid JSON representation of $QuerySpec"
            )
        return querySpecDecoder.decode(argument).getOrThrow()
    }
}