package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.res.AssetFileDescriptor
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.io.session.ContentReadSession
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ThumbnailSize
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import com.ragibn5.content.io.content_io_android.testing.unboxed
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.FileInputStream
import java.io.IOException
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class ContentReadServiceTest {
    private val opener = Mockito.mock(ContentSourceOpener::class.java)
    private val registry = ContentReadSessionRegistry()
    private val request = OpenReadRequest(uri = "content://media/external/images/media/1")
    private val descriptor = OpenedContentSource.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)

    private fun service(scheduler: TestCoroutineScheduler) =
        ContentReadServiceImpl(opener, registry, UnconfinedTestDispatcher(scheduler))

    private fun session(id: String) = Mockito.mock(ContentReadSession::class.java).also {
        Mockito.`when`(it.sessionId).thenReturn(id)
        registry.addSession(it)
    }

    private fun givenOpened(source: Result<OpenedContentSource>) {
        Mockito.doAnswer { unboxed(source) }.`when`(opener).open(request)
    }

    @Test
    fun openReadShouldReturnDescriptorReplyIfContentOpensAsDescriptor() = runTest {
        givenOpened(Result.success(descriptor))

        assertEquals(
            OpenReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true),
            service(testScheduler).openRead(request),
        )
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun openReadShouldReturnChannelReplyAndKeepSessionIfContentOpensAsStream() = runTest {
        givenOpened(Result.success(OpenedContentSource.Stream(ByteArray(0).inputStream())))

        val reply = assertIs<OpenReadReply.Channel>(service(testScheduler).openRead(request))

        assertEquals(setOf(reply.sessionId), registry.sessionMap.keys)
        assertNull(reply.sizeInBytes)
    }

    @Test
    fun openReadShouldThrowIfContentCanNotBeOpened() = runTest {
        givenOpened(Result.failure(ContentIoException(OpenReadExceptionCodes.CONTENT_NOT_FOUND)))

        assertContentIoError(OpenReadExceptionCodes.CONTENT_NOT_FOUND) {
            service(testScheduler).openRead(request)
        }
    }

    @Test
    fun openReadShouldReturnChannelReplyAndKeepSessionIfDescriptorIsKept() = runTest {
        val descriptor = Mockito.mock(AssetFileDescriptor::class.java).also {
            Mockito.`when`(it.length).thenReturn(2048L)
            Mockito.`when`(it.createInputStream()).thenReturn(Mockito.mock(FileInputStream::class.java))
        }
        givenOpened(Result.success(OpenedContentSource.Kept(descriptor)))

        val reply = assertIs<OpenReadReply.Channel>(service(testScheduler).openRead(request))

        assertEquals(setOf(reply.sessionId), registry.sessionMap.keys)
        assertEquals(2048L, reply.sizeInBytes)
    }

    @Test
    fun openThumbnailShouldReturnDescriptorReply() = runTest {
        val thumbnailRequest = OpenThumbnailReadRequest(request.uri, ThumbnailSize(256, 256))
        Mockito.doAnswer { unboxed(Result.success(descriptor)) }.`when`(opener).openThumbnail(thumbnailRequest)

        assertEquals(
            OpenReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true),
            service(testScheduler).openThumbnail(thumbnailRequest),
        )
    }

    @Test
    fun readFromSessionShouldReturnBytesSessionReads() = runTest {
        val session = session("session-1")
        Mockito.`when`(session.read(4, 2)).thenReturn(byteArrayOf(4, 5))

        assertContentEquals(
            byteArrayOf(4, 5),
            service(testScheduler).readFromSession(ReadRequest("session-1", start = 4, length = 2)),
        )
    }

    @Test
    fun readFromSessionShouldThrowSessionNotFoundIfSessionIsNotKept() = runTest {
        val error = assertContentIoError(ReadExceptionCodes.SESSION_NOT_FOUND) {
            service(testScheduler).readFromSession(ReadRequest("session-1", length = 2))
        }

        assertEquals(mapOf("sessionId" to "session-1"), error.details)
    }

    @Test
    fun readFromSessionShouldThrowReadErrorIfSessionReadFails() = runTest {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("Broken pipe") }.`when`(session).read(0, 2)

        assertContentIoError(ReadExceptionCodes.READ_ERROR) {
            service(testScheduler).readFromSession(ReadRequest("session-1", length = 2))
        }
    }

    @Test
    fun closeReadSessionShouldCloseAndForgetSession() = runTest {
        val session = session("session-1")

        service(testScheduler).closeReadSession("session-1")

        Mockito.verify(session).close()
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun closeReadSessionShouldNotThrowIfSessionCloseFails() = runTest {
        val session = session("session-1")
        Mockito.`when`(session.close()).thenThrow(IOException("Already closed"))

        service(testScheduler).closeReadSession("session-1")

        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun closeAllReadSessionsShouldCloseAndForgetEverySession() = runTest {
        val first = session("session-1")
        val second = session("session-2")

        service(testScheduler).closeAllReadSessions()

        Mockito.verify(first).close()
        Mockito.verify(second).close()
        assertTrue(registry.sessionMap.isEmpty())
    }
}
