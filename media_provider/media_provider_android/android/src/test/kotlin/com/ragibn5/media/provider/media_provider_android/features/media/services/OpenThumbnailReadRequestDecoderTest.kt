package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.ThumbnailSize
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenThumbnailReadRequestDecoderTest {
    private val decoder = OpenThumbnailReadRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            OpenThumbnailReadRequest(
                contentUri = "content://media/external/images/media/1",
                size = ThumbnailSize(width = 256, height = 128),
            ),
            decoder.decode(
                """{"contentUri":"content://media/external/images/media/1","size":{"width":256,"height":128}}""",
            ).getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfContentUriIsBlank() {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"contentUri":" ","size":{"width":256,"height":128}}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfSizeIsNotPositive() {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode(
                """{"contentUri":"content://media/external/images/media/1","size":{"width":0,"height":128}}""",
            ).getOrThrow()
        }
    }
}
