package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.GetDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentGetService
import com.ragibn5.document.tree.document_tree_android.features.document.services.GetDocumentRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class GetDocumentRequestHandler(
    private val documentGetService: DocumentGetService,
    private val getDocumentRequestDecoder: GetDocumentRequestDecoder = GetDocumentRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "getDocument"

    override suspend fun handle(call: MethodCall): String? {
        val document = documentGetService.get(parseRequest(call)) ?: return null
        return json.encodeToString(document)
    }

    private fun parseRequest(call: MethodCall): GetDocumentRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentQueryExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${GetDocumentRequest::class.java.simpleName}"
            )
        return getDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
