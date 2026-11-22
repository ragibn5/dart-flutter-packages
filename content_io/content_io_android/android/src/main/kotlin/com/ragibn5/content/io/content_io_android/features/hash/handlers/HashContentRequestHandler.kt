package com.ragibn5.content.io.content_io_android.features.hash.handlers

import com.ragibn5.content.io.content_io_android.MethodCallRequestHandler
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import com.ragibn5.content.io.content_io_android.features.hash.services.ContentHashService
import com.ragibn5.content.io.content_io_android.features.hash.services.HashContentRequestDecoder
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class HashContentRequestHandler(
    private val contentHashService: ContentHashService,
    private val requestDecoder: HashContentRequestDecoder = HashContentRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "hashContent"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return Json.encodeToString(contentHashService.hash(request))
    }

    private fun parseRequest(call: MethodCall): HashContentRequest {
        val argument = call.arguments<String>()
            ?: throw ContentIoException(
                code = OpenReadExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${HashContentRequest::class.java.simpleName}"
            )
        return requestDecoder.decode(argument).getOrThrow()
    }
}
