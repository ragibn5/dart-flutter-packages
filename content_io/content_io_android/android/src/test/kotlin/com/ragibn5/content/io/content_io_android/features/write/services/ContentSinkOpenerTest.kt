package com.ragibn5.content.io.content_io_android.features.write.services

import android.content.ContentResolver
import android.net.Uri
import android.os.ParcelFileDescriptor
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.constants.OpenWriteExceptionCodes
import com.ragibn5.content.io.content_io_android.features.write.models.OpenWriteRequest
import com.ragibn5.content.io.content_io_android.features.write.models.WriteMode
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertSame

internal class ContentSinkOpenerTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val opener = ContentSinkOpener(contentResolver)

    private val request = OpenWriteRequest(uri = CONTENT_URI, mode = WriteMode.APPEND)

    private val uri = Mockito.mock(Uri::class.java)
    private val uris = Mockito.mockStatic(Uri::class.java).also {
        it.`when`<Uri> { Uri.parse(CONTENT_URI) }.thenReturn(uri)
    }

    @AfterEach
    fun tearDown() = uris.close()

    private fun givenOpensAs(descriptor: ParcelFileDescriptor?) {
        Mockito.`when`(contentResolver.openFileDescriptor(uri, "wa")).thenReturn(descriptor)
    }

    private fun givenOpenFails(exception: Exception) {
        Mockito.`when`(contentResolver.openFileDescriptor(uri, "wa")).thenThrow(exception)
    }

    @Test
    fun openShouldReturnDetachedDescriptorIfContentOpensAsDescriptorInRequestedMode() {
        givenOpensAs(Mockito.mock(ParcelFileDescriptor::class.java).also {
            Mockito.`when`(it.detachFd()).thenReturn(FD)
        })

        assertEquals(OpenedContentSink.Descriptor(fd = FD), opener.open(request).getOrThrow())
    }

    @Test
    fun openShouldReturnStreamIfContentDoesNotOpenAsDescriptor() {
        givenOpensAs(null)
        val stream = ByteArrayOutputStream()
        Mockito.`when`(contentResolver.openOutputStream(uri, "wa")).thenReturn(stream)

        assertSame(stream, assertIs<OpenedContentSink.Stream>(opener.open(request).getOrThrow()).stream)
    }

    @Test
    fun openShouldFailWithUnexpectedIfProviderOpensNeitherDescriptorNorStream() {
        givenOpensAs(null)

        assertContentIoError(ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.open(request).getOrThrow()
        }
    }

    @Test
    fun openShouldFailWithContentNotFoundAndUriIfContentDoesNotExist() {
        givenOpenFails(FileNotFoundException("No content"))

        val error = assertContentIoError(OpenWriteExceptionCodes.CONTENT_NOT_FOUND) {
            opener.open(request).getOrThrow()
        }
        assertEquals(mapOf("uri" to CONTENT_URI), error.details)
    }

    @Test
    fun openShouldFailWithContentNotFoundIfProviderNamesMissingDocumentInError() {
        givenOpenFails(IllegalArgumentException("Failed: java.io.FileNotFoundException: Missing file"))

        assertContentIoError(OpenWriteExceptionCodes.CONTENT_NOT_FOUND) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldFailWithPermissionDeniedIfProviderDeniesAccess() {
        givenOpenFails(SecurityException("Permission Denial"))

        assertContentIoError(OpenWriteExceptionCodes.PERMISSION_DENIED) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldFailWithUnsupportedOperationIfProviderCanNotWriteInMode() {
        givenOpenFails(UnsupportedOperationException("Read only"))

        assertContentIoError(OpenWriteExceptionCodes.UNSUPPORTED_OPERATION) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldFailWithInvalidRequestIfUriIsNotContent() {
        givenOpenFails(IllegalArgumentException("Unknown URI"))

        assertContentIoError(OpenWriteExceptionCodes.INVALID_REQUEST) { opener.open(request).getOrThrow() }
    }

    private companion object {
        const val CONTENT_URI = "content://com.android.externalstorage.documents/document/1"
        const val FD = 42
    }
}
