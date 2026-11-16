package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class ShareMediaRequestDecoderTest {
    private val decoder = ShareMediaRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            ShareMediaRequest(contentUris = listOf("content://media/external/images/media/1"), chooserTitle = "Share"),
            decoder.decode(
                """{"contentUris":["content://media/external/images/media/1"],"chooserTitle":"Share"}""",
            ).getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfContentUrisIsEmpty() {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"contentUris":[]}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfAnyContentUriIsBlank() {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"contentUris":["content://media/external/images/media/1"," "]}""").getOrThrow()
        }
    }
}
