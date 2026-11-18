package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.RenameDocumentRequest
import kotlinx.serialization.json.Json

internal class RenameDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<RenameDocumentRequest> = runCatching {
        val request = DocumentRequestChecks.decode<RenameDocumentRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        DocumentRequestChecks.requireName(request.newName)
        return@runCatching request.copy(path = DocumentRequestChecks.requireDocumentPath(request.path))
    }
}
