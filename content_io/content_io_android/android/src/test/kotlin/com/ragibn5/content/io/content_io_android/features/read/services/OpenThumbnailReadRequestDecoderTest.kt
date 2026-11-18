package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ThumbnailSize
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenThumbnailReadRequestDecoderTest {
    private val decoder = OpenThumbnailReadRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            OpenThumbnailReadRequest(
                uri = "content://media/external/images/media/1",
                size = ThumbnailSize(width = 256, height = 128),
            ),
            decoder.decode(
                """{"uri":"content://media/external/images/media/1","size":{"width":256,"height":128}}""",
            ).getOrThrow(),
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
            decoder.decode("""{"uri":" ","size":{"width":256,"height":128}}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfSizeIsNotPositive() {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode(
                """{"uri":"content://media/external/images/media/1","size":{"width":0,"height":128}}""",
            ).getOrThrow()
        }
    }
}
