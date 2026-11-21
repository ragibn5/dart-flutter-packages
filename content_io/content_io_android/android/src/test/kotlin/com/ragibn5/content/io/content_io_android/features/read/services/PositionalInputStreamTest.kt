package com.ragibn5.content.io.content_io_android.features.read.services

import android.system.ErrnoException
import android.system.Os
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito
import java.io.FileDescriptor
import java.io.IOException
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class PositionalInputStreamTest {
    private val fd = FileDescriptor()
    private val content = ByteArray(16) { it.toByte() }
    private val os = Mockito.mockStatic(Os::class.java).also {
        it.`when`<Int> { Os.pread(eq(fd), Mockito.any(ByteArray::class.java), anyInt(), anyInt(), anyLong()) }
            .thenAnswer { call ->
                val buffer = call.getArgument<ByteArray>(1)
                val offset = call.getArgument<Int>(2)
                val count = call.getArgument<Int>(3)
                val position = call.getArgument<Long>(4).toInt()
                val read = minOf(count, content.size - position)
                content.copyInto(buffer, offset, position, position + read)
                read
            }
    }

    @AfterEach
    fun tearDown() {
        os.close()
    }

    @Test
    fun readShouldReadLengthBytesFromStart() {
        val stream = PositionalInputStream(fd, start = 4, length = 6)

        assertContentEquals(byteArrayOf(4, 5, 6, 7, 8, 9), stream.readBytes())
    }

    @Test
    fun readShouldContinueAfterSkippedBytes() {
        val stream = PositionalInputStream(fd, start = 4, length = 6)

        stream.skip(2)

        assertEquals(6, stream.read())
    }

    @Test
    fun skipShouldStopAtLength() {
        val stream = PositionalInputStream(fd, start = 4, length = 6)

        assertEquals(6, stream.skip(100))
    }

    @Test
    fun readShouldFailWithIOExceptionIfDescriptorCantBeRead() {
        os.`when`<Int> { Os.pread(eq(fd), Mockito.any(ByteArray::class.java), anyInt(), anyInt(), anyLong()) }
            .thenThrow(ErrnoException("pread", 5))

        assertFailsWith<IOException> { PositionalInputStream(fd, start = 0, length = 4).read() }
    }
}
