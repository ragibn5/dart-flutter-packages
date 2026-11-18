package com.ragibn5.content.io.content_io_android.features.write.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class OpenWriteRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<OpenWriteRequest> = runCatching {
        val request = try {
            json.decodeFromString<OpenWriteRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${OpenWriteRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${OpenWriteRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.uri.isBlank()) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        ContentIoException(OpenWriteExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
