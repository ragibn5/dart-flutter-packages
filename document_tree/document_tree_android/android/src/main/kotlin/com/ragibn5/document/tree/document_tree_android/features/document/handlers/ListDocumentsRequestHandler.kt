package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.ListDocumentsRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentListService
import com.ragibn5.document.tree.document_tree_android.features.document.services.ListDocumentsRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class ListDocumentsRequestHandler(
    private val documentListService: DocumentListService,
    private val listDocumentsRequestDecoder: ListDocumentsRequestDecoder = ListDocumentsRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "listDocuments"

    override suspend fun handle(call: MethodCall): String {
        val documents = documentListService.list(parseRequest(call))
        return json.encodeToString(documents)
    }

    private fun parseRequest(call: MethodCall): ListDocumentsRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = DocumentQueryExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${ListDocumentsRequest::class.java.simpleName}"
            )
        return listDocumentsRequestDecoder.decode(argument).getOrThrow()
    }
}
