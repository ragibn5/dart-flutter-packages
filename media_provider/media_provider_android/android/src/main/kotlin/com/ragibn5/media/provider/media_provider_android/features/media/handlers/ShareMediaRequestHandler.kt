package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaActionService
import com.ragibn5.media.provider.media_provider_android.features.media.services.ShareMediaRequestDecoder
import io.flutter.plugin.common.MethodCall

internal class ShareMediaRequestHandler(
    private val mediaActionService: MediaActionService,
    private val shareMediaRequestDecoder: ShareMediaRequestDecoder = ShareMediaRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "shareMedia"

    override suspend fun handle(call: MethodCall): Any? {
        mediaActionService.share(parseRequest(call))
        return null
    }

    private fun parseRequest(call: MethodCall): ShareMediaRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = MediaActionExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${ShareMediaRequest::class.java.simpleName}"
            )
        return shareMediaRequestDecoder.decode(argument).getOrThrow()
    }
}
