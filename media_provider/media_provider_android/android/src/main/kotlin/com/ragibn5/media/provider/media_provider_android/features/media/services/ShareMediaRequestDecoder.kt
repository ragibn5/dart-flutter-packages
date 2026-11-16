package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class ShareMediaRequestDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedRequest: String): Result<ShareMediaRequest> = runCatching {
        val request = try {
            json.decodeFromString<ShareMediaRequest>(encodedRequest)
        } catch (e: SerializationException) {
            throw invalidArgument(
                "The input is not a valid JSON representation of ${ShareMediaRequest::class.java.simpleName}",
                e
            )
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message
                    ?: "The input could not be converted to a ${ShareMediaRequest::class.java.simpleName} object",
                e
            )
        }

        if (request.contentUris.isEmpty()) {
            throw invalidArgument("Nothing to share - at least one content uri is required")
        }
        if (request.contentUris.any { it.isBlank() }) {
            throw invalidArgument("Invalid content uri - must be a valid and non-blank")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MediaProviderException(MediaActionExceptionCodes.INVALID_REQUEST, message, cause = cause)
}
