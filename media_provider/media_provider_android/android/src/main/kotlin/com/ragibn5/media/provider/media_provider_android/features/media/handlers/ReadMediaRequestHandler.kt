package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadOpenExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadRequestDecoder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class ReadMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val readRequestDecoder: MediaReadRequestDecoder = MediaReadRequestDecoder(),
    private val errorCodes: MediaReadOpenExceptionCodes = MediaReadOpenExceptionCodes,
) : MethodCallRequestHandler {
    override val method = "openReadSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return Json.encodeToString(mediaStoreService.openReadSession(request))
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