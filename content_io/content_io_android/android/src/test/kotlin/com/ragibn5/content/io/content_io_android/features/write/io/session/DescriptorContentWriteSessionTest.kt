package com.ragibn5.content.io.content_io_android.features.write.io.session

import android.os.ParcelFileDescriptor
import android.system.Os
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.ByteArrayOutputStream
import java.io.FileDescriptor
import java.io.OutputStream
import kotlin.test.assertContentEquals

internal class DescriptorContentWriteSessionTest {
    private val os = Mockito.mockStatic(Os::class.java)
    private val fileDescriptor = FileDescriptor()
    private val descriptor = Mockito.mock(ParcelFileDescriptor::class.java).also {
        Mockito.`when`(it.fileDescriptor).thenReturn(fileDescriptor)
    }

    @AfterEach
    fun tearDown() = os.close()

    @Test
    fun writeShouldWriteBytesToStream() {
        val stream = ByteArrayOutputStream()
        val session = DescriptorContentWriteSession("session-1", descriptor, stream)

        session.write(byteArrayOf(1, 2))
        session.write(byteArrayOf(3))

        assertContentEquals(byteArrayOf(1, 2, 3), stream.toByteArray())
    }

    @Test
    fun syncShouldFlushStreamThenSyncDescriptor() {
        val stream = Mockito.mock(OutputStream::class.java)

        DescriptorContentWriteSession("session-1", descriptor, stream).sync()

        Mockito.verify(stream).flush()
        os.verify { Os.fsync(fileDescriptor) }
    }

    @Test
    fun closeShouldCloseDescriptor() {
        DescriptorContentWriteSession("session-1", descriptor, ByteArrayOutputStream()).close()

        Mockito.verify(descriptor).close()
    }

    @Test
    fun abortShouldCloseDescriptorWithReason() {
        DescriptorContentWriteSession("session-1", descriptor, ByteArrayOutputStream()).abort("Gave up")

        Mockito.verify(descriptor).closeWithError("Gave up")
    }
}
