package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonPrimitive

/**
 * Serves `getMedia`.
 *
 * Expects a `types` argument: a non-empty list of [MediaType] serial names,
 * e.g. `["photo", "video"]`.
 */
internal class GetMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
) : MethodCallRequestHandler {
    override val method = "getMedia"

    override suspend fun handle(call: MethodCall): Any {
        val types = parseTypes(call)
        return withContext(dispatcher) {
            // Encoding a large library is CPU-bound.
            // So the whole reply is built off the main thread.
            // Querying from Default also avoids a hop back to main in between.
            Json.encodeToString(mediaStoreService.getMedia(types))
        }
    }

    private fun parseTypes(call: MethodCall): Set<MediaType> {
        val names = call.argument<Any?>(TYPES_ARGUMENT) as? List<*>
            ?: throw invalidArgument("'$TYPES_ARGUMENT' must be a list")
        if (names.isEmpty()) throw invalidArgument("'$TYPES_ARGUMENT' must not be empty")

        return names.mapTo(mutableSetOf()) { name ->
            if (name !is String) throw invalidArgument("Unknown media type: $name")
            // Decoded through the serializer so @SerialName stays the single
            // source of the wire names.
            try {
                Json.decodeFromJsonElement(MediaType.serializer(), JsonPrimitive(name))
            } catch (e: SerializationException) {
                throw invalidArgument("Unknown media type: $name", e)
            }
        }
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MethodCallException(INVALID_ARGUMENT_CODE, message, cause = cause)

    private companion object {
        private const val TYPES_ARGUMENT = "types"
        private const val INVALID_ARGUMENT_CODE = "invalid_argument"
    }
}
