package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class GetVolumesHandler(
    private val volumeProviderService: VolumeProviderService,
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "getVolumes"

    override suspend fun handle(call: MethodCall): Any {
        val volumes = volumeProviderService.getVolumes()
        return json.encodeToString(volumes)
    }
}
