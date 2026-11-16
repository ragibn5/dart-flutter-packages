package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaQueryExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaType
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeSpec
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class QuerySpecDecoderTest {
    private val decoder = QuerySpecDecoder()

    @Test
    fun decodeShouldReturnSpecIfJsonIsValid() {
        val spec = decoder.decode(
            """{"types":["PHOTO"],"volumes":[{"type":"external","uuid":"1A2B-3C4D","relativePathScope":"DCIM"}]}""",
        ).getOrThrow()

        assertEquals(
            QuerySpec(
                types = setOf(MediaType.PHOTO),
                volumes = setOf(VolumeSpec.External(uuid = "1A2B-3C4D", relativePathScope = "DCIM")),
            ),
            spec,
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertProviderError(MediaQueryExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfTypesIsEmpty() {
        assertProviderError(MediaQueryExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"types":[],"volumes":[{"type":"primary"}]}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfVolumesIsEmpty() {
        assertProviderError(MediaQueryExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"types":["PHOTO"],"volumes":[]}""").getOrThrow()
        }
    }
}
