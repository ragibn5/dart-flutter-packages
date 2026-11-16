package com.ragibn5.media.provider.media_provider_android.features.volume.handlers

import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.testing.mountedVolume
import com.ragibn5.media.provider.media_provider_android.testing.primaryVolumeIdentity
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class GetVolumesHandlerTest {
    @Test
    fun methodShouldBeGetVolumes() {
        assertEquals("getVolumes", GetVolumesHandler({ emptyList() }).method)
    }

    @Test
    fun handleShouldReturnVolumesEncodedAsJson() = runTest {
        val volumes = listOf(mountedVolume(primaryVolumeIdentity))
        val handler = GetVolumesHandler({ volumes }, dispatcher = UnconfinedTestDispatcher(testScheduler))

        val reply = handler.handle(MethodCall("getVolumes", null))

        assertEquals(volumes, Json.decodeFromString<List<VolumeInfo>>(reply))
    }
}
