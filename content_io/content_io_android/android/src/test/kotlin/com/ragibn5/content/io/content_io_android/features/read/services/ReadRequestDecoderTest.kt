package com.ragibn5.content.io.content_io_android.features.read.services

import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class ReadRequestDecoderTest {
    private val decoder = ReadRequestDecoder()

    @Test
    fun decodeShouldReturnRequestIfJsonIsValid() {
        assertEquals(
            ReadRequest(sessionId = "session-1", start = 4, length = 8),
            decoder.decode("""{"sessionId":"session-1","start":4,"length":8}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfJsonIsMalformed() {
        assertContentIoError(ReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("{").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfRequestIsRejected() {
        assertContentIoError(ReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"sessionId":"session-1","start":-1,"length":8}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfSessionIdIsBlank() {
        assertContentIoError(ReadExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"sessionId":" ","start":0,"length":8}""").getOrThrow()
        }
    }
}
