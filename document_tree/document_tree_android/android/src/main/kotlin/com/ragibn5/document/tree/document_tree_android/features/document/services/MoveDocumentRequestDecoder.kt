package com.ragibn5.document.tree.document_tree_android.features.document.services

import com.ragibn5.document.tree.document_tree_android.features.document.models.MoveDocumentRequest
import kotlinx.serialization.json.Json

internal class MoveDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<MoveDocumentRequest> = runCatching {
        val request = DocumentRequestChecks.decode<MoveDocumentRequest>(json, encodedRequest)
        DocumentRequestChecks.requireTreeUri(request.treeUri)
        val path = DocumentRequestChecks.requireDocumentPath(request.path)
        val newParentPath = DocumentRequestChecks.requireFolderPath(request.newParentPath)
        if (newParentPath == path || newParentPath.startsWith("$path/")) {
            throw DocumentRequestChecks.invalid("A folder can't be moved into itself: $path -> $newParentPath")
        }
        return@runCatching request.copy(path = path, newParentPath = newParentPath)
    }
}
