package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentAccessExceptionCodes
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

/**
 * The checks the document requests share.
 *
 * Each throws a [DocumentTreeException] with [DocumentAccessExceptionCodes.INVALID_REQUEST] when
 * its check fails.
 */
internal object DocumentRequestChecks {
    /**
     * [encodedRequest], decoded from JSON into a [T].
     */
    inline fun <reified T> decode(json: Json, encodedRequest: String): T {
        return try {
            json.decodeFromString<T>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalid("The input is not a valid JSON representation of ${T::class.java.simpleName}", e)
        } catch (e: IllegalArgumentException) {
            throw invalid(e.message ?: "The input could not be converted to a ${T::class.java.simpleName} object", e)
        }
    }

    /**
     * Returns if [treeUri] is a tree's URI.
     */
    fun requireTreeUri(treeUri: String) {
        if (!DocumentsContract.isTreeUri(treeUri.toUri())) {
            throw invalid("Not a document tree uri: $treeUri")
        }
    }

    /**
     * [path], normalized, if it names a document rather than the tree's root.
     */
    fun requireDocumentPath(path: String): String {
        val normalized = DocumentPaths.normalize(path)
        if (normalized.isNullOrEmpty()) {
            throw invalid(
                "Invalid path - it must name a document, and its segments must be non-empty, " +
                    "and not `.` or `..`: $path"
            )
        }
        return normalized
    }

    /**
     * [path], normalized; empty for the tree's root.
     */
    fun requireFolderPath(path: String): String {
        return DocumentPaths.normalize(path)
            ?: throw invalid("Invalid path - its segments must be non-empty, and not `.` or `..`: $path")
    }

    /**
     * Returns if [name] can name a document: it's not empty, `.` or `..`, and has no `/`.
     */
    fun requireName(name: String) {
        if (name.isEmpty() || name == "." || name == ".." || name.contains('/')) {
            throw invalid("Invalid name - it must not be empty, `.` or `..`, or contain `/`: $name")
        }
    }

    fun invalid(message: String, cause: Throwable? = null) =
        DocumentTreeException(DocumentAccessExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
