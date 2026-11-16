package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenMediaWithRequestDecoderTest {
    private val decoder = OpenMediaWithRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            OpenMediaWithRequest(contentUri = "content://media/external/images/media/1", chooserTitle = "Open with"),
            decoder.decode(
                """{"contentUri":"content://media/external/images/media/1","chooserTitle":"Open with"}""",
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
    fun decodeShouldFailWithInvalidRequestIfContentUriIsBlank() {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"contentUri":" "}""").getOrThrow()
        }
    }
}
