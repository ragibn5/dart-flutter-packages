package com.ragibn5.media.provider.media_provider_android.features.media.services

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.io.session.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.ThumbnailSize
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import com.ragibn5.media.provider.media_provider_android.testing.unboxed
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.IOException
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class MediaReadServiceTest {
    private val opener = Mockito.mock(MediaSourceOpener::class.java)
    private val registry = MediaReadSessionRegistry()
    private val request = OpenMediaReadRequest(contentUri = "content://media/external/images/media/1")
    private val descriptor = OpenedMediaSource.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)

    private fun service(scheduler: TestCoroutineScheduler) =
        MediaReadServiceImpl(opener, registry, UnconfinedTestDispatcher(scheduler))

    private fun session(id: String) = Mockito.mock(MediaReadSession::class.java).also {
        Mockito.`when`(it.sessionId).thenReturn(id)
        registry.addSession(it)
    }

    private fun givenOpened(source: Result<OpenedMediaSource>) {
        Mockito.doAnswer { unboxed(source) }.`when`(opener).open(request)
    }

    @Test
    fun openReadShouldReturnDescriptorReplyIfItemOpensAsDescriptor() = runTest {
        givenOpened(Result.success(descriptor))

        assertEquals(
            OpenMediaReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true),
            service(testScheduler).openRead(request),
        )
        assertTrue(registry.sessionMap.isEmpty())
    }

    @Test
    fun openReadShouldReturnChannelReplyAndKeepSessionIfItemOpensAsStream() = runTest {
        givenOpened(Result.success(OpenedMediaSource.Stream(ByteArray(0).inputStream())))

        val reply = assertIs<OpenMediaReadReply.Channel>(service(testScheduler).openRead(request))

        assertEquals(setOf(reply.sessionId), registry.sessionMap.keys)
        assertNull(reply.sizeInBytes)
    }

    @Test
    fun openReadShouldThrowIfItemCanNotBeOpened() = runTest {
        givenOpened(Result.failure(MediaProviderException(OpenMediaReadExceptionCodes.MEDIA_NOT_FOUND)))

        assertProviderError(OpenMediaReadExceptionCodes.MEDIA_NOT_FOUND) {
            service(testScheduler).openRead(request)
        }
    }

    @Test
    fun openThumbnailShouldReturnDescriptorReply() = runTest {
        val thumbnailRequest = OpenThumbnailReadRequest(request.contentUri, ThumbnailSize(256, 256))
        Mockito.doAnswer { unboxed(Result.success(descriptor)) }.`when`(opener).openThumbnail(thumbnailRequest)

        assertEquals(
            OpenMediaReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true),
            service(testScheduler).openThumbnail(thumbnailRequest),
        )
    }

    @Test
    fun readFromSessionShouldReturnBytesSessionReads() = runTest {
        val session = session("session-1")
        Mockito.`when`(session.read(4, 2)).thenReturn(byteArrayOf(4, 5))

        assertContentEquals(
            byteArrayOf(4, 5),
            service(testScheduler).readFromSession(MediaReadRequest("session-1", start = 4, length = 2)),
        )
    }

    @Test
    fun readFromSessionShouldThrowSessionNotFoundIfSessionIsNotKept() = runTest {
        val error = assertProviderError(MediaReadExceptionCodes.SESSION_NOT_FOUND) {
            service(testScheduler).readFromSession(MediaReadRequest("session-1", length = 2))
        }

        assertEquals(mapOf("sessionId" to "session-1"), error.details)
    }

    @Test
    fun readFromSessionShouldThrowReadErrorIfSessionReadFails() = runTest {
        val session = session("session-1")
        Mockito.doAnswer { throw IOException("Broken pipe") }.`when`(session).read(0, 2)

        assertProviderError(MediaReadExceptionCodes.READ_ERROR) {
            service(testScheduler).readFromSession(MediaReadRequest("session-1", length = 2))
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
