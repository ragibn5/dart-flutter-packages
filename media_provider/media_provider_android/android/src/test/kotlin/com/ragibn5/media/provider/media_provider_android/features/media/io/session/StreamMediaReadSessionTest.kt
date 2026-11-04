package com.ragibn5.media.provider.media_provider_android.features.media.io.session

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import java.io.ByteArrayInputStream
import java.io.FilterInputStream
import kotlin.test.assertContentEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class StreamMediaReadSessionTest {
    /** A stream over [bytes] that serves at most [pieceSize] bytes per read. */
    private class PiecewiseStream(bytes: ByteArray, private val pieceSize: Int) :
        FilterInputStream(ByteArrayInputStream(bytes)) {
        var isClosed = false
            private set

        override fun read(b: ByteArray, off: Int, len: Int): Int = super.read(b, off, minOf(len, pieceSize))

        override fun close() {
            isClosed = true
            super.close()
        }
    }

    private val stream = PiecewiseStream(byteArrayOf(0, 1, 2, 3, 4, 5), pieceSize = 2)
    private val session = StreamMediaReadSession("session-1", stream)

    @Test
    fun sizeInBytesShouldBeNull() {
        assertNull(session.sizeInBytes)
    }

    @Test
    fun isSeekableShouldBeFalse() {
        assertFalse(session.isSeekable)
    }

    @Test
    fun readShouldFillLengthIfStreamServesFewerBytesPerRead() {
        assertContentEquals(byteArrayOf(0, 1, 2, 3, 4), session.read(start = 0, length = 5))
    }

    @Test
    fun readShouldContinueWhereThePreviousReadEnded() {
        session.read(start = 0, length = 2)

        assertContentEquals(byteArrayOf(2, 3), session.read(start = 2, length = 2))
    }

    @Test
    fun readShouldReturnFewerBytesIfStreamEndsFirst() {
        assertContentEquals(byteArrayOf(0, 1, 2, 3, 4, 5), session.read(start = 0, length = 10))
    }

    @Test
    fun readShouldThrowInvalidRequestIfStartIsNotWhereThePreviousReadEnded() {
        assertProviderError(MediaReadExceptionCodes.INVALID_REQUEST) {
            session.read(start = 3, length = 2)
        }
    }

    @Test
    fun closeShouldCloseStream() {
        session.close()

        assertTrue(stream.isClosed)
    }
}
