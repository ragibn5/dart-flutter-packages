package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

internal class GetPhotosRequestHandler(
    private val mediaStoreService: MediaStoreService,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Default,
) : MethodCallRequestHandler {
    override val method = "getPhotos"

    override suspend fun handle(call: MethodCall): Any = withContext(dispatcher) {
        // Encoding a large library is CPU-bound.
        // So the whole reply is built off the main thread.
        // Querying from Default also avoids a hop back to main in between.
        Json.encodeToString(mediaStoreService.getPhotos())
    }
}
