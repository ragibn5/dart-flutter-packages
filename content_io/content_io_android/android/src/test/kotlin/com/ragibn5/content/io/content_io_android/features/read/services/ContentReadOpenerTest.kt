package com.ragibn5.content.io.content_io_android.features.read.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.net.Uri
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import android.system.StructStat
import com.ragibn5.content.io.content_io_android.exceptions.ContentIoCommonExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ThumbnailSize
import com.ragibn5.content.io.content_io_android.testing.anyOf
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.FileDescriptor
import java.io.FileNotFoundException
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertSame

internal class ContentReadOpenerTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val videoFrameThumbnails = Mockito.mock(VideoFrameThumbnails::class.java)
    private val opener = ContentReadOpener(contentResolver, videoFrameThumbnails)

    private val request = OpenReadRequest(uri = CONTENT_URI)
    private val thumbnailRequest = OpenThumbnailReadRequest(CONTENT_URI, ThumbnailSize(256, 256))

    private val uri = Mockito.mock(Uri::class.java)
    private val uris = Mockito.mockStatic(Uri::class.java).also {
        it.`when`<Uri> { Uri.parse(CONTENT_URI) }.thenReturn(uri)
    }
    private val os = Mockito.mockStatic(Os::class.java)
    private val osConstants = Mockito.mockStatic(OsConstants::class.java)

    @AfterEach
    fun tearDown() {
        uris.close()
        os.close()
        osConstants.close()
    }

    /**
     * A descriptor of [length] bytes from [offset] in a file of [fileSize]
     * bytes, which is a regular file when [isRegularFile].
     */
    private fun descriptor(
        length: Long = 2048,
        offset: Long = 0,
        fileSize: Long = 2048,
        isRegularFile: Boolean = true,
    ): AssetFileDescriptor {
        val fileDescriptor = FileDescriptor()
        val stat = Mockito.mock(StructStat::class.java).also {
            StructStat::class.java.getField("st_mode").apply { isAccessible = true }.setInt(it, MODE)
            StructStat::class.java.getField("st_size").apply { isAccessible = true }.setLong(it, fileSize)
        }
        os.`when`<StructStat> { Os.fstat(fileDescriptor) }.thenReturn(stat)
        osConstants.`when`<Boolean> { OsConstants.S_ISREG(MODE) }.thenReturn(isRegularFile)

        val parcel = Mockito.mock(ParcelFileDescriptor::class.java)
        Mockito.`when`(parcel.detachFd()).thenReturn(FD)
        return Mockito.mock(AssetFileDescriptor::class.java).also {
            Mockito.`when`(it.fileDescriptor).thenReturn(fileDescriptor)
            Mockito.`when`(it.length).thenReturn(length)
            Mockito.`when`(it.startOffset).thenReturn(offset)
            Mockito.`when`(it.parcelFileDescriptor).thenReturn(parcel)
        }
    }

    /** A descriptor its provider watches for how the read ends. */
    private fun watchedDescriptor(): AssetFileDescriptor {
        val parcel = Mockito.mock(ParcelFileDescriptor::class.java)
        Mockito.`when`(parcel.canDetectErrors()).thenReturn(true)
        return Mockito.mock(AssetFileDescriptor::class.java).also {
            Mockito.`when`(it.parcelFileDescriptor).thenReturn(parcel)
        }
    }

    private fun givenOpensAs(descriptor: AssetFileDescriptor?) {
        Mockito.`when`(contentResolver.openAssetFileDescriptor(uri, "r")).thenReturn(descriptor)
    }

    private fun givenOpenFails(exception: Exception) {
        Mockito.`when`(contentResolver.openAssetFileDescriptor(uri, "r")).thenThrow(exception)
    }

    private fun givenThumbnailOpensAs(descriptor: AssetFileDescriptor?) {
        Mockito.`when`(
            contentResolver.openTypedAssetFileDescriptor(
                Mockito.eq(uri),
                Mockito.eq("image/*"),
                anyOf(Bundle::class.java),
            ),
        ).thenReturn(descriptor)
    }

    @Test
    fun openShouldReturnDetachedDescriptorIfContentOpensAsDescriptor() {
        givenOpensAs(descriptor(length = 1024, offset = 512, fileSize = 4096))

        assertEquals(
            OpenedForRead.DetachedFd(fd = FD, offset = 512, sizeInBytes = 1024, isSeekable = true),
            opener.open(request).getOrThrow(),
        )
    }

    @Test
    fun openShouldUseFileSizeAfterOffsetIfLengthIsUnknownAndFileIsRegular() {
        givenOpensAs(descriptor(length = AssetFileDescriptor.UNKNOWN_LENGTH, offset = 512, fileSize = 4096))

        assertEquals(3584L, assertIs<OpenedForRead.DetachedFd>(opener.open(request).getOrThrow()).sizeInBytes)
    }

    @Test
    fun openShouldReportNoSizeAndNoSeekingIfLengthIsUnknownAndFileIsNotRegular() {
        givenOpensAs(descriptor(length = AssetFileDescriptor.UNKNOWN_LENGTH, isRegularFile = false))

        val opened = assertIs<OpenedForRead.DetachedFd>(opener.open(request).getOrThrow())

        assertEquals(null to false, opened.sizeInBytes to opened.isSeekable)
    }

    @Test
    fun openShouldFailWithUnexpectedAndCloseDescriptorIfItCanNotBeInspected() {
        val descriptor = descriptor()
        os.`when`<StructStat> { Os.fstat(descriptor.fileDescriptor) }.thenThrow(ErrnoException("fstat", 9))
        givenOpensAs(descriptor)

        assertContentIoError(ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.open(request).getOrThrow()
        }
        Mockito.verify(descriptor).close()
    }

    @Test
    fun openShouldKeepDescriptorWithoutDetachingIfProviderWatchesIt() {
        val descriptor = watchedDescriptor()
        givenOpensAs(descriptor)

        assertSame(descriptor, assertIs<OpenedForRead.WatchedAssetFd>(opener.open(request).getOrThrow()).descriptor)
        Mockito.verify(descriptor.parcelFileDescriptor, Mockito.never()).detachFd()
    }

    @Test
    fun openShouldReturnStreamIfContentDoesNotOpenAsDescriptor() {
        val stream = ByteArray(0).inputStream()
        givenOpensAs(null)
        Mockito.`when`(contentResolver.openInputStream(uri)).thenReturn(stream)

        assertSame(stream, assertIs<OpenedForRead.FallbackStream>(opener.open(request).getOrThrow()).stream)
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

        val error = assertContentIoError(OpenReadExceptionCodes.CONTENT_NOT_FOUND) {
            opener.open(request).getOrThrow()
        }
        assertEquals(mapOf("uri" to CONTENT_URI), error.details)
    }

    @Test
    fun openShouldFailWithContentNotFoundAndUriIfProviderNamesMissingDocumentInError() {
        givenOpenFails(
            IllegalArgumentException(
                "Failed to determine if primary:a/b.jpg is child of primary:a: " +
                    "java.io.FileNotFoundException: Missing file for primary:a/b.jpg"
            )
        )

        val error = assertContentIoError(OpenReadExceptionCodes.CONTENT_NOT_FOUND) {
            opener.open(request).getOrThrow()
        }
        assertEquals(mapOf("uri" to CONTENT_URI), error.details)
    }

    @Test
    fun openShouldFailWithPermissionDeniedIfProviderDeniesAccess() {
        givenOpenFails(SecurityException("Permission Denial"))

        assertContentIoError(OpenReadExceptionCodes.PERMISSION_DENIED) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldFailWithInvalidRequestIfUriIsNotContent() {
        givenOpenFails(IllegalArgumentException("Unknown URI"))

        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openThumbnailShouldReturnDetachedDescriptorOfImage() {
        givenThumbnailOpensAs(descriptor(length = 1024))

        assertEquals(
            OpenedForRead.DetachedFd(fd = FD, offset = 0, sizeInBytes = 1024, isSeekable = true),
            opener.openThumbnail(thumbnailRequest).getOrThrow(),
        )
    }

    @Test
    fun openThumbnailShouldKeepDescriptorIfProviderWatchesIt() {
        val descriptor = watchedDescriptor()
        givenThumbnailOpensAs(descriptor)

        assertSame(
            descriptor,
            assertIs<OpenedForRead.WatchedAssetFd>(opener.openThumbnail(thumbnailRequest).getOrThrow()).descriptor,
        )
    }

    @Test
    fun openThumbnailShouldFailWithUnexpectedIfProviderOpensNothing() {
        givenThumbnailOpensAs(null)

        assertContentIoError(ContentIoCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.openThumbnail(thumbnailRequest).getOrThrow()
        }
    }

    @Test
    fun openThumbnailShouldReturnVideoFrameIfProviderMakesNoThumbnail() {
        val frame = byteArrayOf(1, 2, 3)
        Mockito.`when`(videoFrameThumbnails.isNeeded(uri)).thenReturn(true)
        Mockito.`when`(videoFrameThumbnails.readFrameAsJpeg(uri, 256, 256)).thenReturn(frame)

        val opened = assertIs<OpenedForRead.FallbackStream>(opener.openThumbnail(thumbnailRequest).getOrThrow())

        assertContentEquals(frame, opened.stream.readBytes())
    }

    @Test
    fun openThumbnailShouldFailWithContentNotFoundIfVideoHasNoFrame() {
        Mockito.`when`(videoFrameThumbnails.isNeeded(uri)).thenReturn(true)
        Mockito.`when`(videoFrameThumbnails.readFrameAsJpeg(uri, 256, 256))
            .thenThrow(FileNotFoundException("No frame"))

        assertContentIoError(OpenReadExceptionCodes.CONTENT_NOT_FOUND) {
            opener.openThumbnail(thumbnailRequest).getOrThrow()
        }
    }

    private companion object {
        const val CONTENT_URI = "content://media/external/images/media/1"
        const val FD = 42
        const val MODE = 0x8000
    }
}
