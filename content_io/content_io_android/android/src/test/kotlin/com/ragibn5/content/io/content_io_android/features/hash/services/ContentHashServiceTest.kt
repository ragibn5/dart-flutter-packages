package com.ragibn5.content.io.content_io_android.features.hash.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHash
import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHashAlgorithm
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadOpener
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import com.ragibn5.content.io.content_io_android.testing.unboxed
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.ByteArrayInputStream
import java.io.IOException
import java.io.InputStream
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class ContentHashServiceTest {
    private val opener = Mockito.mock(ContentReadOpener::class.java)
    private val request = HashContentRequest(uri = CONTENT_URI, algorithm = ContentHashAlgorithm.SHA_256)

    private fun service(scheduler: TestCoroutineScheduler) =
        ContentHashServiceImpl(opener, UnconfinedTestDispatcher(scheduler))

    private fun givenOpens(result: Result<InputStream>) {
        Mockito.doAnswer { unboxed(result) }.`when`(opener).openStream(OpenReadRequest(CONTENT_URI))
    }

    @Test
    fun hashShouldReturnSha256OfWholeContent() = runTest {
        givenOpens(Result.success(ByteArrayInputStream("hello".toByteArray())))

        assertEquals(
            ContentHash(ContentHashAlgorithm.SHA_256, HELLO_SHA_256),
            service(testScheduler).hash(request),
        )
    }

    @Test
    fun hashShouldReturnSha256OfEmptyContentIfContentIsEmpty() = runTest {
        givenOpens(Result.success(ByteArrayInputStream(ByteArray(0))))

        assertEquals(
            ContentHash(ContentHashAlgorithm.SHA_256, EMPTY_SHA_256),
            service(testScheduler).hash(request),
        )
    }

    @Test
    fun hashShouldCloseContentAfterHashingIt() = runTest {
        var isClosed = false
        givenOpens(Result.success(object : ByteArrayInputStream("hello".toByteArray()) {
            override fun close() {
                isClosed = true
            }
        }))

        service(testScheduler).hash(request)

        assertTrue(isClosed)
    }

    @Test
    fun hashShouldFailWithOpenErrorIfContentCanNotBeOpened() = runTest {
        givenOpens(Result.failure(ContentIoException(OpenReadExceptionCodes.CONTENT_NOT_FOUND)))

        assertContentIoError(OpenReadExceptionCodes.CONTENT_NOT_FOUND) { service(testScheduler).hash(request) }
    }

    @Test
    fun hashShouldFailWithReadErrorAndCloseContentIfReadingFails() = runTest {
        var isClosed = false
        givenOpens(Result.success(object : InputStream() {
            override fun read(): Int = throw IOException("Gone")

            override fun read(b: ByteArray, off: Int, len: Int): Int = throw IOException("Gone")

            override fun close() {
                isClosed = true
            }
        }))

        assertContentIoError(ReadExceptionCodes.READ_ERROR) { service(testScheduler).hash(request) }
        assertTrue(isClosed)
    }

    private companion object {
        const val CONTENT_URI = "content://media/external/images/media/1"

        /** `printf hello | sha256sum` */
        const val HELLO_SHA_256 = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"

        /** `printf '' | sha256sum` */
        const val EMPTY_SHA_256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }
}
