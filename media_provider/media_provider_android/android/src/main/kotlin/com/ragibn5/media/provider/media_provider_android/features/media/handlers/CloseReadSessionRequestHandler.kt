package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import io.flutter.plugin.common.MethodCall

internal class CloseReadSessionRequestHandler(
    private val mediaStoreService: MediaStoreService,
) : MethodCallRequestHandler {
    override val method = "closeReadSession"

    override suspend fun handle(call: MethodCall): Any? {
        val sessionId = call.argument<String>("sessionId")
            ?: throw MediaProviderException(
                code = OpenMediaReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass the `sessionId` of the session to close"
            )
        mediaStoreService.closeReadSession(sessionId)
        return null
    }
}
