package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.ListDocumentsRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class ListDocumentsRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<ListDocumentsRequest> = runCatching {
        val request = try {
            json.decodeFromString<ListDocumentsRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${ListDocumentsRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${ListDocumentsRequest::class.java.simpleName} object",
                e
            )
        }

        if (!DocumentsContract.isTreeUri(request.treeUri.toUri())) {
            throw invalidArgument("Not a document tree uri: ${request.treeUri}")
        }

        // `/DCIM/Camera/` and `DCIM/Camera` are the same folder.
        val path = request.path.trim('/')
        if (path.isNotEmpty() && path.split('/').any { it.isEmpty() || it == "." || it == ".." }) {
            throw invalidArgument("Invalid path - its segments must be non-empty, and not `.` or `..`: ${request.path}")
        }

        return@runCatching request.copy(path = path)
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        DocumentTreeException(DocumentQueryExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
