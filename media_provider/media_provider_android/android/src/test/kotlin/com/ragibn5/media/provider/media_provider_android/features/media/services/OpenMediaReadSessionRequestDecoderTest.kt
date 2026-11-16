package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenMediaReadSessionRequestDecoderTest {
    private val decoder = OpenMediaReadSessionRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            OpenMediaReadRequest(contentUri = "content://media/external/images/media/1"),
            decoder.decode("""{"contentUri":"content://media/external/images/media/1"}""").getOrThrow(),
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
            decoder.decode("""{"contentUri":" "}""").getOrThrow()
        }
    }
}
