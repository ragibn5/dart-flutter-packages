package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class MediaReadRequestDecoderTest {
    private val decoder = MediaReadRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            MediaReadRequest(sessionId = "session-1", start = 4, length = 8),
            decoder.decode("""{"sessionId":"session-1","start":4,"length":8}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertProviderError(MediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfRequestIsRejected() {
        assertProviderError(MediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"sessionId":"session-1","start":-1,"length":8}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfSessionIdIsBlank() {
        assertProviderError(MediaReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"sessionId":" ","start":0,"length":8}""").getOrThrow()
        }
    }
}
