package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDirectoryRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.CreateDirectoryRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DirectoryCreateService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class CreateDirectoryRequestHandler(
    private val directoryCreateService: DirectoryCreateService,
    private val createDirectoryRequestDecoder: CreateDirectoryRequestDecoder = CreateDirectoryRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "createDirectory"

    override suspend fun handle(call: MethodCall): String {
        val folder = directoryCreateService.create(parseRequest(call))
        return json.encodeToString(folder)
    }

    private fun parseRequest(call: MethodCall): CreateDirectoryRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${CreateDirectoryRequest::class.java.simpleName}"
            )
        return createDirectoryRequestDecoder.decode(argument).getOrThrow()
    }
}
