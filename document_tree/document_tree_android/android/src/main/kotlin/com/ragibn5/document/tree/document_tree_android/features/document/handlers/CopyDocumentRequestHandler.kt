package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CopyDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.CopyDocumentRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCopyService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class CopyDocumentRequestHandler(
    private val documentCopyService: DocumentCopyService,
    private val copyDocumentRequestDecoder: CopyDocumentRequestDecoder = CopyDocumentRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "copyDocument"

    override suspend fun handle(call: MethodCall): String {
        val document = documentCopyService.copy(parseRequest(call))
        return json.encodeToString(document)
    }

    private fun parseRequest(call: MethodCall): CopyDocumentRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${CopyDocumentRequest::class.java.simpleName}"
            )
        return copyDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
