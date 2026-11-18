package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.MethodCallRequestHandler
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.read.services.OpenReadRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class OpenReadRequestHandler(
    private val contentReadService: ContentReadService,
    private val requestDecoder: OpenReadRequestDecoder = OpenReadRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openReadSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        // Encoded as the sealed type, so the reply carries its `kind`.
        return Json.encodeToString<OpenReadReply>(contentReadService.openRead(request))
    }

    private fun parseRequest(call: MethodCall): OpenReadRequest {
        val argument = call.arguments<String>()
            ?: throw ContentIoException(
                code = OpenReadExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenReadRequest::class.java.simpleName}"
            )
        return requestDecoder.decode(argument).getOrThrow()
    }
}