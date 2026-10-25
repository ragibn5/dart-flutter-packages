package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaActionService
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenMediaWithRequestDecoder
import io.flutter.plugin.common.MethodCall

internal class OpenMediaWithRequestHandler(
    private val mediaActionService: MediaActionService,
    private val openMediaWithRequestDecoder: OpenMediaWithRequestDecoder = OpenMediaWithRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openMediaWith"

    override suspend fun handle(call: MethodCall): Any? {
        mediaActionService.openWith(parseRequest(call))
        return null
    }

    private fun parseRequest(call: MethodCall): OpenMediaWithRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = MediaActionExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenMediaWithRequest::class.java.simpleName}"
            )
        return openMediaWithRequestDecoder.decode(argument).getOrThrow()
    }
}
