package com.ragibn5.document.tree.document_tree_android.features.tree.services

import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.tree.constants.TreePickExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.tree.models.PickTreeRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class PickTreeRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<PickTreeRequest> = runCatching {
        val request = try {
            json.decodeFromString<PickTreeRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${PickTreeRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${PickTreeRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.initialUri?.isBlank() == true) {
            throw invalidArgument("Invalid initial uri - must be null, or a valid and non-blank uri")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        DocumentTreeException(TreePickExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
