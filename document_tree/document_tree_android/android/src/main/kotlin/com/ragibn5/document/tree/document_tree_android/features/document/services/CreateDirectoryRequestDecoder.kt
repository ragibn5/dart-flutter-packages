package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDirectoryRequest
import kotlinx.serialization.json.Json

internal class CreateDirectoryRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<CreateDirectoryRequest> = runCatching {
        val request = DocumentRequestChecks.decode<CreateDirectoryRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        return@runCatching request.copy(path = DocumentRequestChecks.requireDocumentPath(request.path))
    }
}
