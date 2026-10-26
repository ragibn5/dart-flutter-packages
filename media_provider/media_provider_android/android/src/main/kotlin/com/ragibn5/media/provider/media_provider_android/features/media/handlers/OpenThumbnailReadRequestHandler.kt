package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadService
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenThumbnailReadRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class OpenThumbnailReadRequestHandler(
    private val mediaReadService: MediaReadService,
    private val openThumbnailReadRequestDecoder: OpenThumbnailReadRequestDecoder = OpenThumbnailReadRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openThumbnailReadSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        // Encoded as the sealed type, so the reply carries its `kind`.
        return Json.encodeToString<OpenMediaReadReply>(mediaReadService.openThumbnail(request))
    }

    private fun parseRequest(call: MethodCall): OpenThumbnailReadRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = OpenMediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenThumbnailReadRequest::class.java.simpleName}"
            )
        return openThumbnailReadRequestDecoder.decode(argument).getOrThrow()
    }
}
