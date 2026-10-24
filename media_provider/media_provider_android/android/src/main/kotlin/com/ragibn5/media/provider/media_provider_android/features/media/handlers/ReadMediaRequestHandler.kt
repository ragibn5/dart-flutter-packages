package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadRequestDecoder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.utils.timed
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class ReadMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val mediaReadRequestDecoder: MediaReadRequestDecoder = MediaReadRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "readFromSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = timed("[readFromSession] native decode request") { parseRequest(call) }
        return mediaStoreService.readFromSession(request)
    }

    private fun parseRequest(call: MethodCall): MediaReadRequest {
        val argument = call.arguments<String>()
            ?: throw MediaProviderException(
                code = OpenMediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass a valid JSON representation of $OpenMediaReadRequest"
            )
        return mediaReadRequestDecoder.decode(argument).getOrThrow()
    }
}