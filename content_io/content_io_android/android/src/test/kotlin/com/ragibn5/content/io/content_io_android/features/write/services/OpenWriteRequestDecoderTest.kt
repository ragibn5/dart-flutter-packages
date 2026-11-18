package com.ragibn5.content.io.content_io_android.features.write.services

import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.models.WriteMode
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenWriteRequestDecoderTest {
    private val decoder = OpenWriteRequestDecoder()

    @Test
    fun decodeShouldReturnRequestWithTruncateModeIfModeIsTruncate() {
        assertEquals(
            OpenWriteRequest(uri = URI, mode = WriteMode.TRUNCATE),
            decoder.decode("""{"uri":"$URI","mode":"truncate"}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldReturnRequestWithAppendModeIfModeIsAppend() {
        assertEquals(
            OpenWriteRequest(uri = URI, mode = WriteMode.APPEND),
            decoder.decode("""{"uri":"$URI","mode":"append"}""").getOrThrow(),
        )
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfInputIsNotJson() {
        assertContentIoError(OpenWriteExceptionCodes.INVALID_REQUEST) { decoder.decode("{").getOrThrow() }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfModeIsUnknown() {
        assertContentIoError(OpenWriteExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"uri":"$URI","mode":"overwrite"}""").getOrThrow()
        }
    }

    @Test
    fun decodeShouldFailWithInvalidRequestIfUriIsBlank() {
        assertContentIoError(OpenWriteExceptionCodes.INVALID_REQUEST) {
            decoder.decode("""{"uri":" ","mode":"truncate"}""").getOrThrow()
        }
    }

    private companion object {
        const val URI = "content://com.android.externalstorage.documents/document/1"
    }
}
