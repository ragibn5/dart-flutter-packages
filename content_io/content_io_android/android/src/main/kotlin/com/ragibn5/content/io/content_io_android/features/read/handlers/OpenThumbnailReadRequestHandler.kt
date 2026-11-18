package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.MethodCallRequestHandler
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.read.services.OpenThumbnailReadRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class OpenThumbnailReadRequestHandler(
    private val contentReadService: ContentReadService,
    private val openThumbnailReadRequestDecoder: OpenThumbnailReadRequestDecoder = OpenThumbnailReadRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openThumbnailReadSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        // Encoded as the sealed type, so the reply carries its `kind`.
        return Json.encodeToString<OpenReadReply>(contentReadService.openThumbnail(request))
    }

    private fun parseRequest(call: MethodCall): OpenThumbnailReadRequest {
        val argument = call.arguments<String>()
            ?: throw ContentIoException(
                code = OpenReadExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenThumbnailReadRequest::class.java.simpleName}"
            )
        return openThumbnailReadRequestDecoder.decode(argument).getOrThrow()
    }
}
