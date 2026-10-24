package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.utils.timed
import java.io.BufferedInputStream
import java.io.File
import java.util.UUID

internal class MediaReadSessionFactory(
    private val contentResolver: ContentResolver,
    private val fileLocationResolver: FileLocationResolver,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    val sdkInt: Int = Build.VERSION.SDK_INT
) {
    fun create(request: OpenMediaReadRequest): Result<MediaReadSession> = runCatching {
        if (!isPermissionAvailable()) {
            throw MediaProviderException(
                OpenMediaReadExceptionCodes.PERMISSION_DENIED,
                "The required permissions for reading the media item is not granted"
            )
        }

        val mediaColumn = timed("[openMediaReadSession] native query") {
            contentResolver.query(
                request.contentUri.toUri(),
                mediaColumnsReaderFactory.projection.toTypedArray(),
                null, null, null
            )?.use {
                if (!it.moveToFirst()) {
                    throw MediaProviderException(
                        OpenMediaReadExceptionCodes.MEDIA_NOT_FOUND,
                        "The requested media item does not seem to exist"
                    )
                }

                val reader = mediaColumnsReaderFactory.create(it)
                return@use reader.read()
            } ?: throw MediaProviderException(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The media provider is not responding, we probably need a device restart"
            )
        }

        val fileLocation = mediaColumn.data?.let { fileLocationResolver.resolve(it) }
        val backingFile = fileLocation?.absoluteFilePath?.let { File(it) }
            ?.let { if(it.exists() && it.canRead()) it else null }
        return@runCatching MediaReadSession(
            sessionId = UUID.randomUUID().toString(),
            contentUri = request.contentUri,
            sizeInBytes = mediaColumn.sizeInBytes ?: backingFile?.length(),
            isSeekable = backingFile != null
        ).apply {
            // One descriptor backs everything: the channel for the channel reads,
            // and /proc/self/fd/<n> for the direct reads from Dart.
            val pfd = contentResolver.openFileDescriptor(request.contentUri.toUri(), "r")
                ?: throw MediaProviderException(
                    MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                    "Failed to open the media item for reading"
                )
            // Closes pfd when closed.
            val input = ParcelFileDescriptor.AutoCloseInputStream(pfd)
            descriptor = pfd
            channel = input.channel
            stream = BufferedInputStream(input)
            descriptorPath = "/proc/self/fd/${pfd.fd}"
            descriptorFd = pfd.fd
        }
    }

    private fun isPermissionAvailable(): Boolean {
        // TODO: Implement actual logic here
        return true
    }
}