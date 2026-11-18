package com.ragibn5.content.io.content_io_android.features.read.io.session

import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.Test
import java.io.ByteArrayInputStream
import java.io.FilterInputStream
import kotlin.test.assertContentEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class StreamContentReadSessionTest {
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
    private val session = StreamContentReadSession("session-1", stream)

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
        assertContentIoError(ReadExceptionCodes.INVALID_REQUEST) {
            session.read(start = 3, length = 2)
        }
    }

    @Test
    fun closeShouldCloseStream() {
        session.close()

        assertTrue(stream.isClosed)
    }
}
