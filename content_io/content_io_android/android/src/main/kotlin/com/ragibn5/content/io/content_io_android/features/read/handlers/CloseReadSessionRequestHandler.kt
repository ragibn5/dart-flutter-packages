package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.MethodCallRequestHandler
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import io.flutter.plugin.common.MethodCall

internal class CloseReadSessionRequestHandler(
    private val contentReadService: ContentReadService,
) : MethodCallRequestHandler {
    override val method = "closeReadSession"

    override suspend fun handle(call: MethodCall): Any? {
        val sessionId = call.argument<String>("sessionId")
            ?: throw ContentIoException(
                code = ReadExceptionCodes.INVALID_REQUEST,
                message = "You must pass the `sessionId` of the session to close"
            )
        contentReadService.closeReadSession(sessionId)
        return null
    }
}
