package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.MoveDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.MoveDocumentRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMoveService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class MoveDocumentRequestHandler(
    private val documentMoveService: DocumentMoveService,
    private val moveDocumentRequestDecoder: MoveDocumentRequestDecoder = MoveDocumentRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "moveDocument"

    override suspend fun handle(call: MethodCall): String {
        val document = documentMoveService.move(parseRequest(call))
        return json.encodeToString(document)
    }

    private fun parseRequest(call: MethodCall): MoveDocumentRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${MoveDocumentRequest::class.java.simpleName}"
            )
        return moveDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
