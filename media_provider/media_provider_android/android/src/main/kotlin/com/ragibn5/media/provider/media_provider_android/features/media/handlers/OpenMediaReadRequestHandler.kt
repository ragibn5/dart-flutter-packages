package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenMediaReadSessionRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class OpenMediaReadRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val openMediaReadSessionRequestDecoder: OpenMediaReadSessionRequestDecoder = OpenMediaReadSessionRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openMediaReadSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        // Encoded as the sealed type, so the reply carries its `kind`.
        return Json.encodeToString<OpenMediaReadReply>(mediaStoreService.openRead(request))
    }

    private fun parseRequest(call: MethodCall): OpenMediaReadRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = OpenMediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenMediaReadRequest::class.java.simpleName}"
            )
        return openMediaReadSessionRequestDecoder.decode(argument).getOrThrow()
    }
}