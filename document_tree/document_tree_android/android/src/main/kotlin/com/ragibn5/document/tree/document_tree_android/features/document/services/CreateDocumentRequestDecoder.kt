package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDocumentRequest
import kotlinx.serialization.json.Json

internal class CreateDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<CreateDocumentRequest> = runCatching {
        val request = DocumentRequestChecks.decode<CreateDocumentRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        if (request.mimeType != null && request.mimeType.isBlank()) {
            throw DocumentRequestChecks.invalid("The MIME type must not be blank")
        }
        return@runCatching request.copy(path = DocumentRequestChecks.requireDocumentPath(request.path))
    }
}
