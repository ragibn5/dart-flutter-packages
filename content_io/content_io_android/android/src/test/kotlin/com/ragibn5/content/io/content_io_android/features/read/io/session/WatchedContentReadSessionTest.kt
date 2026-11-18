package com.ragibn5.content.io.content_io_android.features.read.io.session

import android.content.res.AssetFileDescriptor
import android.os.ParcelFileDescriptor
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.InputStream
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull

internal class WatchedContentReadSessionTest {
    private val parcel = Mockito.mock(ParcelFileDescriptor::class.java)

    private fun descriptor(length: Long) = Mockito.mock(AssetFileDescriptor::class.java).also {
        Mockito.`when`(it.length).thenReturn(length)
        Mockito.`when`(it.parcelFileDescriptor).thenReturn(parcel)
    }

    private fun session(
        content: ByteArray,
        length: Long = AssetFileDescriptor.UNKNOWN_LENGTH,
        stream: InputStream = content.inputStream(),
    ) = WatchedContentReadSession("session-1", descriptor(length), stream)

    @Test
    fun sizeInBytesShouldBeDescriptorLengthIfKnown() {
        assertEquals(3L, session(byteArrayOf(1, 2, 3), length = 3).sizeInBytes)
    }

    @Test
    fun sizeInBytesShouldBeNullIfDescriptorLengthIsUnknown() {
        assertNull(session(byteArrayOf(1, 2, 3)).sizeInBytes)
    }

    @Test
    fun isSeekableShouldBeFalse() {
        assertFalse(session(byteArrayOf(1)).isSeekable)
    }

    @Test
    fun readShouldReturnBytesInOrder() {
        val session = session(byteArrayOf(1, 2, 3))

        assertContentEquals(byteArrayOf(1, 2), session.read(0, 2))
        assertContentEquals(byteArrayOf(3), session.read(2, 2))
    }

    @Test
    fun closeShouldCloseCleanlyIfReadReachedEnd() {
        val stream = Mockito.spy(byteArrayOf(1, 2).inputStream())
        val session = session(byteArrayOf(1, 2), stream = stream)
        session.read(0, 4)

        session.close()

        Mockito.verify(stream).close()
        Mockito.verify(parcel, Mockito.never()).closeWithError(Mockito.anyString())
    }

    @Test
    fun closeShouldCloseCleanlyIfReadReachedKnownSize() {
        val stream = Mockito.spy(byteArrayOf(1, 2).inputStream())
        val session = session(byteArrayOf(1, 2), length = 2, stream = stream)
        session.read(0, 2)

        session.close()

        Mockito.verify(stream).close()
    }

    @Test
    fun closeShouldTellProviderReadWasCancelledIfItEndedEarly() {
        val session = session(byteArrayOf(1, 2, 3))
        session.read(0, 1)

        session.close()

        Mockito.verify(parcel).closeWithError("The read was cancelled")
    }
}
