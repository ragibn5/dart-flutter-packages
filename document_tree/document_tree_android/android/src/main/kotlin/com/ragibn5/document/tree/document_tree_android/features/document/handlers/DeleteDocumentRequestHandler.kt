package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DeleteDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.DeleteDocumentRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentDeleteService
import io.flutter.plugin.common.MethodCall

internal class DeleteDocumentRequestHandler(
    private val documentDeleteService: DocumentDeleteService,
    private val deleteDocumentRequestDecoder: DeleteDocumentRequestDecoder = DeleteDocumentRequestDecoder(),
) : MethodCallRequestHandler {
    override val method = "deleteDocument"

    override suspend fun handle(call: MethodCall): Any? {
        documentDeleteService.delete(parseRequest(call))
        return null
    }

    private fun parseRequest(call: MethodCall): DeleteDocumentRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${DeleteDocumentRequest::class.java.simpleName}"
            )
        return deleteDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
