package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeState
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class GetVolumesHandlerTest {
    private val service = FakeVolumeProviderService()
    private val handler = GetVolumesHandler(service)

    private fun call() = MethodCall("getVolumes", null)

    @Test
    fun `serves the method the Dart side calls`() {
        assertEquals("getVolumes", handler.method)
    }

    @Test
    fun `replies with the service's volumes encoded as JSON`() = runTest {
        service.items = listOf(
            primaryVolume(),
            secondaryVolume(),
        )

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(call()),
        )
    }

    @Test
    fun `replies with volumes the caller can decode back`() = runTest {
        service.items = listOf(
            primaryVolume(),
            secondaryVolume(),
        )

        val reply = handler.handle(call()) as String

        assertEquals(service.items, Json.decodeFromString<List<VolumeInfo>>(reply))
    }

    @Test
    fun `replies with an empty JSON array when the device has no volumes`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(call()))
    }

    private companion object {
        fun primaryVolume() = VolumeInfo(
            state = VolumeState.MOUNTED,
            availableSpaceInBytes = 1024,
            identity = VolumeIdentity(
                isPrimary = true,
                isRemovable = false,
                isEmulated = true,
                uuid = null,
                capacityInBytes = 4096,
                type = VolumeType.PRIMARY,
            ),
        )

        fun secondaryVolume() = VolumeInfo(
            state = VolumeState.MOUNTED_READ_ONLY,
            availableSpaceInBytes = 512,
            identity = VolumeIdentity(
                isPrimary = false,
                isRemovable = true,
                isEmulated = false,
                uuid = "1234-5678",
                capacityInBytes = 2048,
                type = VolumeType.SD_CARD,
            ),
        )
    }

    private class FakeVolumeProviderService : VolumeProviderService {
        var items: List<VolumeInfo> = emptyList()

        override fun getVolumes(): List<VolumeInfo> = items
    }
}
