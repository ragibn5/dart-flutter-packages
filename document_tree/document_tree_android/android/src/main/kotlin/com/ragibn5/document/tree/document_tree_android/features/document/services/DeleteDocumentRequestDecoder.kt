package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.DeleteDocumentRequest
import kotlinx.serialization.json.Json

internal class DeleteDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<DeleteDocumentRequest> = runCatching {
        val request = DocumentRequestChecks.decode<DeleteDocumentRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        return@runCatching request.copy(path = DocumentRequestChecks.requireDocumentPath(request.path))
    }
}
