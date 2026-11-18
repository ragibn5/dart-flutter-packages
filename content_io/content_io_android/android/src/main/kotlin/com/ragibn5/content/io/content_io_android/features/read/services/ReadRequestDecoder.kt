package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class ReadRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<ReadRequest> = runCatching {
        val request = try {
            json.decodeFromString<ReadRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${ReadRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${ReadRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.sessionId.isBlank()) {
            throw invalidArgument("Invalid session id - must be a valid session id obtained from `openReadSession`")
        }
        if (request.start < 0) {
            throw invalidArgument("Invalid start offset - must be >=0")
        }
        if (request.length < 0) {
            throw invalidArgument("Invalid length - must be >= 0")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        ContentIoException(ReadExceptionCodes.INVALID_REQUEST, message, cause = cause)
}