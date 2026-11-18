package com.ragibn5.content.io.content_io_android.features.write.services

import android.os.ParcelFileDescriptor
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.constants.WriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.io.session.ContentWriteSession
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteReply
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.models.WriteMode
import com.ragibn5.content.io.content_io_android.testing.anyOf
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import com.ragibn5.content.io.content_io_android.testing.unboxed
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.FileDescriptor
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

internal class ContentWriteServiceTest {
    private val opener = Mockito.mock(ContentSinkOpener::class.java)
    private val registry = ContentWriteSessionRegistry()
    private val request = OpenWriteRequest(uri = "content://a/document/1", mode = WriteMode.TRUNCATE)

    private fun service(scheduler: TestCoroutineScheduler = TestCoroutineScheduler()) =
        ContentWriteServiceImpl(opener, registry, UnconfinedTestDispatcher(scheduler))

    private fun session(id: String) = Mockito.mock(ContentWriteSession::class.java).also {
        Mockito.`when`(it.sessionId).thenReturn(id)
        registry.addSession(it)
    }

    private fun givenOpened(sink: Result<OpenedContentSink>) {
        Mockito.doAnswer { unboxed(sink) }.`when`(opener).open(request)
    }

    @Test
    fun openWriteShouldReturnDescriptorReplyAndKeepNoSessionIfContentOpensAsDescriptor() = runTest {
        givenOpened(Result.success(OpenedContentSink.Descriptor(fd = 42)))

        assertEquals(OpenWriteReply.Descriptor(fd = 42), service(testScheduler).openWrite(request))
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun openWriteShouldReturnChannelReplyAndKeepSessionIfDescriptorIsKept() = runTest {
        val descriptor = Mockito.mock(ParcelFileDescriptor::class.java).also {
            Mockito.`when`(it.fileDescriptor).thenReturn(FileDescriptor())
        }
        givenOpened(Result.success(OpenedContentSink.Kept(descriptor)))

        val reply = assertIs<OpenWriteReply.Channel>(service(testScheduler).openWrite(request))

        assertEquals(setOf(reply.sessionId), registry.sessionMap.keys)
    }

    @Test
    fun openWriteShouldThrowIfContentCanNotBeOpened() = runTest {
        givenOpened(Result.failure(ContentIoException(OpenWriteExceptionCodes.CONTENT_NOT_FOUND)))

        assertContentIoError(OpenWriteExceptionCodes.CONTENT_NOT_FOUND) {
            service(testScheduler).openWrite(request)
        }
    }

    @Test
    fun writeToSessionShouldWriteBytesToSession() {
        val session = session("session-1")
        val bytes = byteArrayOf(1, 2)

        service().writeToSession("session-1", bytes)

        Mockito.verify(session).write(bytes)
    }

    @Test
    fun writeToSessionShouldThrowSessionNotFoundWithIdIfSessionIsNotKept() {
        val error = assertContentIoError(WriteExceptionCodes.SESSION_NOT_FOUND) {
            service().writeToSession("session-1", byteArrayOf(1))
        }

        assertEquals(mapOf("sessionId" to "session-1"), error.details)
    }

    @Test
    fun writeToSessionShouldThrowWriteErrorIfSessionWriteFails() {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("Broken pipe") }.`when`(session).write(anyOf(ByteArray::class.java))

        assertContentIoError(WriteExceptionCodes.WRITE_ERROR) {
            service().writeToSession("session-1", byteArrayOf(1))
        }
    }

    @Test
    fun writeToSessionShouldThrowNotEnoughSpaceIfVolumeIsFull() {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("write failed: ENOSPC (No space left on device)") }
            .`when`(session).write(anyOf(ByteArray::class.java))

        assertContentIoError(WriteExceptionCodes.NOT_ENOUGH_SPACE) {
            service().writeToSession("session-1", byteArrayOf(1))
        }
    }

    @Test
    fun closeWriteSessionShouldSyncCloseAndForgetSession() {
        val session = session("session-1")

        service().closeWriteSession("session-1")

        val order = Mockito.inOrder(session)
        order.verify(session).sync()
        order.verify(session).close()
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun closeWriteSessionShouldThrowNotEnoughSpaceAbortAndForgetIfSyncFindsVolumeFull() {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("fsync failed: ENOSPC (No space left on device)") }
            .`when`(session).sync()

        assertContentIoError(WriteExceptionCodes.NOT_ENOUGH_SPACE) { service().closeWriteSession("session-1") }

        Mockito.verify(session).abort(Mockito.anyString())
        Mockito.verify(session, Mockito.never()).close()
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun closeWriteSessionShouldThrowWriteErrorIfSessionCloseFails() {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("Remote error") }.`when`(session).close()

        assertContentIoError(WriteExceptionCodes.WRITE_ERROR) { service().closeWriteSession("session-1") }
    }

    @Test
    fun closeWriteSessionShouldThrowSessionNotFoundIfSessionIsNotKept() {
        assertContentIoError(WriteExceptionCodes.SESSION_NOT_FOUND) { service().closeWriteSession("session-1") }
    }

    @Test
    fun abortWriteSessionShouldAbortWithoutSyncAndForgetSession() {
        val session = session("session-1")

        service().abortWriteSession("session-1")

        Mockito.verify(session).abort("The write was aborted")
        Mockito.verify(session, Mockito.never()).sync()
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun abortWriteSessionShouldNotThrowIfSessionAbortFails() {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("Already closed") }.`when`(session).abort(Mockito.anyString())

        service().abortWriteSession("session-1")

        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun abortWriteSessionShouldDoNothingIfSessionIsNotKept() {
        service().abortWriteSession("session-1")

        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun abortAllWriteSessionsShouldAbortAndForgetEverySession() {
        val first = session("session-1")
        val second = session("session-2")

        service().abortAllWriteSessions()

        Mockito.verify(first).abort("The write was aborted")
        Mockito.verify(second).abort("The write was aborted")
        assertTrue(registry.sessionMap.isEmpty())
    }
}
