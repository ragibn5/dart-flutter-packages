package com.ragibn5.content.io.content_io_android.features.write.io.session

import android.system.Os
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileDescriptor
import java.io.FileOutputStream
import java.io.OutputStream
import kotlin.test.assertContentEquals

internal class StreamContentWriteSessionTest {
    private val os = Mockito.mockStatic(Os::class.java)

    @AfterEach
    fun tearDown() = os.close()

    @Test
    fun writeShouldWriteBytesToStream() {
        val stream = ByteArrayOutputStream()
        val session = StreamContentWriteSession("session-1", stream)

        session.write(byteArrayOf(1, 2))
        session.write(byteArrayOf(3))

        assertContentEquals(byteArrayOf(1, 2, 3), stream.toByteArray())
    }

    @Test
    fun syncShouldOnlyFlushIfStreamIsNotFileStream() {
        val stream = Mockito.mock(OutputStream::class.java)

        StreamContentWriteSession("session-1", stream).sync()

        Mockito.verify(stream).flush()
        os.verifyNoInteractions()
    }

    @Test
    fun syncShouldSyncDescriptorIfStreamIsFileStream() {
        val file = File.createTempFile("session", ".bin").apply { deleteOnExit() }
        FileOutputStream(file).use { stream ->
            StreamContentWriteSession("session-1", stream).sync()

            os.verify { Os.fsync(Mockito.any(FileDescriptor::class.java)) }
        }
    }

    @Test
    fun closeShouldCloseStream() {
        val stream = Mockito.mock(OutputStream::class.java)

        StreamContentWriteSession("session-1", stream).close()

        Mockito.verify(stream).close()
    }
}
