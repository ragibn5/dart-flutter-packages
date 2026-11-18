package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenReadRequestDecoderTest {
    private val decoder = OpenReadRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            OpenReadRequest(uri = "content://media/external/images/media/1"),
            decoder.decode("""{"uri":"content://media/external/images/media/1"}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfContentUriIsBlank() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"uri":" "}""").getOrThrow()
        }
    }
}
