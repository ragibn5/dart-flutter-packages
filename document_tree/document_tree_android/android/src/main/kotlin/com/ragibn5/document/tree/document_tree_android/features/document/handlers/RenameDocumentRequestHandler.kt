package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.RenameDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.RenameDocumentRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRenameService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class RenameDocumentRequestHandler(
    private val documentRenameService: DocumentRenameService,
    private val renameDocumentRequestDecoder: RenameDocumentRequestDecoder = RenameDocumentRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "renameDocument"

    override suspend fun handle(call: MethodCall): String {
        val document = documentRenameService.rename(parseRequest(call))
        return json.encodeToString(document)
    }

    private fun parseRequest(call: MethodCall): RenameDocumentRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${RenameDocumentRequest::class.java.simpleName}"
            )
        return renameDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
