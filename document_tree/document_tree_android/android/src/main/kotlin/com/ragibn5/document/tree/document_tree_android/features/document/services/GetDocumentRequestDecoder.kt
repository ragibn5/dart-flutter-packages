package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.GetDocumentRequest
import kotlinx.serialization.json.Json

internal class GetDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<GetDocumentRequest> = runCatching {
        val request = DocumentRequestChecks.decode<GetDocumentRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        return@runCatching request.copy(path = DocumentRequestChecks.requireFolderPath(request.path))
    }
}
