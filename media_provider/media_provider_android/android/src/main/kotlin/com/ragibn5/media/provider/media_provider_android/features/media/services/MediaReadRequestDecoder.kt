package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadOpenExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class MediaReadRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
    private val errorCodes: MediaReadOpenExceptionCodes = MediaReadOpenExceptionCodes,
) {
    fun decode(encodedRequest: String): Result<MediaReadRequest> = runCatching {
        val request = try {
            json.decodeFromString<MediaReadRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${MediaReadRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${MediaReadRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.contentUri.isBlank()) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MediaProviderException(errorCodes.INVALID_REQUEST, message, cause = cause)
}