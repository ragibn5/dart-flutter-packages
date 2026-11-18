package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class OpenThumbnailReadRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<OpenThumbnailReadRequest> = runCatching {
        val request = try {
            json.decodeFromString<OpenThumbnailReadRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${OpenThumbnailReadRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${OpenThumbnailReadRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.uri.isBlank()) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }
        if (request.size.width <= 0 || request.size.height <= 0) {
            throw invalidArgument("Invalid thumbnail size - width and height must be > 0")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        ContentIoException(OpenReadExceptionCodes.INVALID_REQUEST, message, cause = cause)
}