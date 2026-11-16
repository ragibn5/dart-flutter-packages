package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CopyDocumentRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class CopyDocumentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<CopyDocumentRequest> = runCatching {
        val request = try {
            json.decodeFromString<CopyDocumentRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${CopyDocumentRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${CopyDocumentRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.sourceUri.toUri().scheme.isNullOrEmpty()) {
            throw invalidArgument("The source uri has no scheme: ${request.sourceUri}")
        }
        if (!DocumentsContract.isTreeUri(request.treeUri.toUri())) {
            throw invalidArgument("Not a document tree uri: ${request.treeUri}")
        }

        val path = DocumentPaths.normalize(request.path)
        if (path.isNullOrEmpty()) {
            throw invalidArgument(
                "Invalid path - it must name a file, and its segments must be non-empty, " +
                    "and not `.` or `..`: ${request.path}"
            )
        }
        if (request.mimeType != null && request.mimeType.isBlank()) {
            throw invalidArgument("The MIME type must not be blank")
        }

        return@runCatching request.copy(path = path)
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        DocumentTreeException(DocumentWriteExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
