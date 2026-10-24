package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaQueryExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class QuerySpecDecoder(
    private val json: Json = Json { ignoreUnknownKeys = true },
) {
    fun decode(encodedQuerySpec: String): Result<QuerySpec> = runCatching {
        val request = try {
            json.decodeFromString<QuerySpec>(encodedQuerySpec)
        } catch (e: SerializationException) {
            throw invalidArgument("The input is not a valid JSON representation of ${QuerySpec::class.java.simpleName}", e)
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(
                e.message ?: "The input could not be converted to a ${QuerySpec::class.java.simpleName} object", e
            )
        }

        if (request.types.isEmpty()) {
            throw invalidArgument("'${QuerySpec::types}' must not be empty")
        }
        if (request.volumes.isEmpty()) {
            throw invalidArgument("'${QuerySpec::volumes}' must not be empty")
        }

        return@runCatching request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MediaProviderException(MediaQueryExceptionCodes.INVALID_REQUEST, message, cause = cause)
}