package com.ragibn5.media.provider.media_provider_android.features.volume.models

import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class VolumeSpecTest {
    @Test
    fun decodeShouldReturnPrimaryIfTypeIsPrimary() {
        assertEquals(
            VolumeSpec.Primary(relativePathScope = "DCIM"),
            Json.decodeFromString<VolumeSpec>("""{"type":"primary","relativePathScope":"DCIM"}"""),
        )
    }

    @Test
    fun decodeShouldReturnExternalIfTypeIsExternal() {
        assertEquals(
            VolumeSpec.External(uuid = "1A2B-3C4D", relativePathScope = "DCIM"),
            Json.decodeFromString<VolumeSpec>("""{"type":"external","uuid":"1A2B-3C4D","relativePathScope":"DCIM"}"""),
        )
    }

    @Test
    fun decodeShouldUseEmptyScopeIfRelativePathScopeIsMissing() {
        assertEquals(
            VolumeSpec.Primary(relativePathScope = ""),
            Json.decodeFromString<VolumeSpec>("""{"type":"primary"}"""),
        )
    }
}
