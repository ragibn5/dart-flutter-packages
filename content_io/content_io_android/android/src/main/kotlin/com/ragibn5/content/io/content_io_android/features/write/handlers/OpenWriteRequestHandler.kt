package com.ragibn5.content.io.content_io_android.features.write.handlers

import com.ragibn5.content.io.content_io_android.MethodCallRequestHandler
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteReply
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteService
import com.ragibn5.content.io.content_io_android.features.write.services.OpenWriteRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class OpenWriteRequestHandler(
    private val contentWriteService: ContentWriteService,
    private val requestDecoder: OpenWriteRequestDecoder = OpenWriteRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "openWriteSession"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        // Encoded as the sealed type, so the reply carries its `kind`.
        return Json.encodeToString<OpenWriteReply>(contentWriteService.openWrite(request))
    }

    private fun parseRequest(call: MethodCall): OpenWriteRequest {
        val argument = call.arguments<String>()
            ?: throw ContentIoException(
                code = OpenWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${OpenWriteRequest::class.java.simpleName}"
            )
        return requestDecoder.decode(argument).getOrThrow()
    }
}
