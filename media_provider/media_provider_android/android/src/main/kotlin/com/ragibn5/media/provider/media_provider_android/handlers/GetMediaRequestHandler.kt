package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json

internal class GetMediaRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val json: Json = Json { ignoreUnknownKeys = true },
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
) : MethodCallRequestHandler {
    override val method = "getMedia"

    override suspend fun handle(call: MethodCall): Any {
        val request = parseRequest(call)
        return withContext(dispatcher) {
            // Encoding a large library is CPU-bound.
            // So the whole reply is built off the main thread.
            // Querying from Default also avoids a hop back to main in between.
            Json.encodeToString(mediaStoreService.getMedia(request))
        }
    }

    private fun parseRequest(call: MethodCall): QuerySpec {
        val argument = call.argument<String>(QUERY_ARGUMENT)
            ?: throw invalidArgument("'$QUERY_ARGUMENT' must be a valid JSON representation of $QuerySpec")

        val request = try {
            json.decodeFromString<QuerySpec>(argument)
        } catch (e: SerializationException) {
            throw invalidArgument("'$QUERY_ARGUMENT' is malformed", e)
        } catch (e: IllegalArgumentException) {
            throw invalidArgument(e.message ?: "'$QUERY_ARGUMENT' is malformed", e)
        }

        if (request.types.isEmpty()) {
            throw invalidArgument("'types' must not be empty")
        }
        if (request.volumes.isEmpty()) {
            throw invalidArgument("'volumes' must not be empty")
        }

        return request
    }

    private fun invalidArgument(message: String, cause: Throwable? = null) =
        MethodCallException(INVALID_ARGUMENT_CODE, message, cause = cause)

    private companion object {
        private const val QUERY_ARGUMENT = "query"
        private const val INVALID_ARGUMENT_CODE = "invalid_argument"
    }
}
