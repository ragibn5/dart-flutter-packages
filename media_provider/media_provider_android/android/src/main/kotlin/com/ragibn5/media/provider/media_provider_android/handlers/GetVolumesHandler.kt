package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.MethodCallRequestHandler
import com.ragibn5.media.provider.media_provider_android.services.VolumesInfoProviderService
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class GetVolumesHandler(
    private val volumesInfoProviderService: VolumesInfoProviderService,
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "getVolumes"

    override suspend fun handle(call: MethodCall): Any {
        val volumes = volumesInfoProviderService.getVolumes()
        return json.encodeToString(volumes)
    }
}
