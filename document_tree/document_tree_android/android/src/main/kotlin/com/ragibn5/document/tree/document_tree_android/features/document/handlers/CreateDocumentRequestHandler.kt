package com.ragibn5.document.tree.document_tree_android.features.document.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.services.CreateDocumentRequestDecoder
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreateService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

/**
 * Serves `createDocument`, whose arguments are a map: the request's JSON under `request`, and
 * the file's content, if any, as raw bytes under `bytes`, so they skip the JSON.
 */
internal class CreateDocumentRequestHandler(
    private val documentCreateService: DocumentCreateService,
    private val createDocumentRequestDecoder: CreateDocumentRequestDecoder = CreateDocumentRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "createDocument"

    override suspend fun handle(call: MethodCall): String {
        val document = documentCreateService.create(parseRequest(call), call.argument<ByteArray>("bytes"))
        return json.encodeToString(document)
    }

    private fun parseRequest(call: MethodCall): CreateDocumentRequest {
        val argument = call.argument<String>("request")
            ?: throw DocumentTreeException(
                code = DocumentWriteExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${CreateDocumentRequest::class.java.simpleName}"
            )
        return createDocumentRequestDecoder.decode(argument).getOrThrow()
    }
}
