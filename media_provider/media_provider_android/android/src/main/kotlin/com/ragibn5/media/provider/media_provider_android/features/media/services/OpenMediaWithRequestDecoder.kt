package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class OpenMediaWithRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<OpenMediaWithRequest> = runCatching {
        val request = try {
            json.decodeFromString<OpenMediaWithRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${OpenMediaWithRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${OpenMediaWithRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.contentUri.isBlank()) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MediaProviderException(MediaActionExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
