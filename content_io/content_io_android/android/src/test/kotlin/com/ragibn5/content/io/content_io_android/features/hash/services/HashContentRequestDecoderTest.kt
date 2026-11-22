package com.ragibn5.content.io.content_io_android.features.hash.services

import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHashAlgorithm
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class HashContentRequestDecoderTest {
    private val decoder = HashContentRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            HashContentRequest(uri = "content://media/external/images/media/1", algorithm = ContentHashAlgorithm.SHA_256),
            decoder.decode("""{"uri":"content://media/external/images/media/1","algorithm":"sha256"}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfAlgorithmIsUnknown() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"uri":"content://media/external/images/media/1","algorithm":"md4"}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfContentUriIsBlank() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"uri":" ","algorithm":"sha256"}""").getOrThrow()
        }
    }
}
