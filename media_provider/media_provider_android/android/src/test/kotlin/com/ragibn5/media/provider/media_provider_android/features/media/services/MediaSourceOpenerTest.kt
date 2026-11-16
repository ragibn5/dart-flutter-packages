package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.content.res.AssetFileDescriptor
import android.net.Uri
import android.os.Bundle
import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import android.system.StructStat
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.ThumbnailSize
import com.ragibn5.media.provider.media_provider_android.testing.anyOf
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.FileDescriptor
import java.io.FileNotFoundException
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertSame

internal class MediaSourceOpenerTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private var isPermissionGranted = true
    private val opener = MediaSourceOpener(contentResolver) { isPermissionGranted }

    private val request = OpenMediaReadRequest(contentUri = CONTENT_URI)
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
    fun openShouldFailWithPermissionDeniedIfPermissionIsNotGranted() {
        isPermissionGranted = false

        assertProviderError(OpenMediaReadExceptionCodes.PERMISSION_DENIED) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldReturnDetachedDescriptorIfItemOpensAsDescriptor() {
        givenOpensAs(descriptor(length = 1024, offset = 512, fileSize = 4096))

        assertEquals(
            OpenedMediaSource.Descriptor(fd = FD, offset = 512, sizeInBytes = 1024, isSeekable = true),
            opener.open(request).getOrThrow(),
        )
    }

    @Test
    fun openShouldUseFileSizeAfterOffsetIfLengthIsUnknownAndFileIsRegular() {
        givenOpensAs(descriptor(length = AssetFileDescriptor.UNKNOWN_LENGTH, offset = 512, fileSize = 4096))

        assertEquals(3584L, assertIs<OpenedMediaSource.Descriptor>(opener.open(request).getOrThrow()).sizeInBytes)
    }

    @Test
    fun openShouldReportNoSizeAndNoSeekingIfLengthIsUnknownAndFileIsNotRegular() {
        givenOpensAs(descriptor(length = AssetFileDescriptor.UNKNOWN_LENGTH, isRegularFile = false))

        val source = assertIs<OpenedMediaSource.Descriptor>(opener.open(request).getOrThrow())

        assertEquals(null to false, source.sizeInBytes to source.isSeekable)
    }

    @Test
    fun openShouldFailWithUnexpectedAndCloseDescriptorIfItCanNotBeInspected() {
        val descriptor = descriptor()
        os.`when`<StructStat> { Os.fstat(descriptor.fileDescriptor) }.thenThrow(ErrnoException("fstat", 9))
        givenOpensAs(descriptor)

        assertProviderError(MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.open(request).getOrThrow()
        }
        Mockito.verify(descriptor).close()
    }

    @Test
    fun openShouldReturnStreamIfItemDoesNotOpenAsDescriptor() {
        val stream = ByteArray(0).inputStream()
        givenOpensAs(null)
        Mockito.`when`(contentResolver.openInputStream(uri)).thenReturn(stream)

        assertSame(stream, assertIs<OpenedMediaSource.Stream>(opener.open(request).getOrThrow()).stream)
    }

    @Test
    fun openShouldFailWithUnexpectedIfProviderOpensNeitherDescriptorNorStream() {
        givenOpensAs(null)

        assertProviderError(MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.open(request).getOrThrow()
        }
    }

    @Test
    fun openShouldFailWithMediaNotFoundAndUriIfItemDoesNotExist() {
        givenOpenFails(FileNotFoundException("No item"))

        val error = assertProviderError(OpenMediaReadExceptionCodes.MEDIA_NOT_FOUND) {
            opener.open(request).getOrThrow()
        }
        assertEquals(mapOf("uri" to CONTENT_URI), error.details)
    }

    @Test
    fun openShouldFailWithPermissionDeniedIfProviderDeniesAccess() {
        givenOpenFails(SecurityException("Permission Denial"))

        assertProviderError(OpenMediaReadExceptionCodes.PERMISSION_DENIED) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openShouldFailWithInvalidRequestIfUriIsNotAnItem() {
        givenOpenFails(IllegalArgumentException("Unknown URI"))

        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) { opener.open(request).getOrThrow() }
    }

    @Test
    fun openThumbnailShouldFailWithPermissionDeniedIfPermissionIsNotGranted() {
        isPermissionGranted = false

        assertProviderError(OpenMediaReadExceptionCodes.PERMISSION_DENIED) {
            opener.openThumbnail(thumbnailRequest).getOrThrow()
        }
    }

    @Test
    fun openThumbnailShouldReturnDetachedDescriptorOfImage() {
        givenThumbnailOpensAs(descriptor(length = 1024))

        assertEquals(
            OpenedMediaSource.Descriptor(fd = FD, offset = 0, sizeInBytes = 1024, isSeekable = true),
            opener.openThumbnail(thumbnailRequest).getOrThrow(),
        )
    }

    @Test
    fun openThumbnailShouldFailWithUnexpectedIfProviderOpensNothing() {
        givenThumbnailOpensAs(null)

        assertProviderError(MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED) {
            opener.openThumbnail(thumbnailRequest).getOrThrow()
        }
    }

    private companion object {
        const val CONTENT_URI = "content://media/external/images/media/1"
        const val FD = 42
        const val MODE = 0x8000
    }
}
