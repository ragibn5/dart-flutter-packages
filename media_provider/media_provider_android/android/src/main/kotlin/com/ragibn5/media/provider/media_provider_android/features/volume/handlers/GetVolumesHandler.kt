package com.ragibn5.media.provider.media_provider_android.features.volume.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json

internal class GetVolumesHandler(
    private val volumeProviderService: VolumeProviderService,
    private val json: Json = Json { ignoreUnknownKeys = true },
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MethodCallRequestHandler {
    override val method = "getVolumes"

    override suspend fun handle(call: MethodCall): String = withContext(dispatcher) {
        // Asks StorageManager and StatFs, which block, so it runs off the main thread.
        val volumes = volumeProviderService.getVolumes()
        return@withContext json.encodeToString(volumes)
    }
}