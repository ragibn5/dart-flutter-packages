package com.ragibn5.content.io.content_io_android.features.hash.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class HashContentRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<HashContentRequest> = runCatching {
        val request = try {
            json.decodeFromString<HashContentRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${HashContentRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${HashContentRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.uri.isBlank()) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        ContentIoException(OpenReadExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
