package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.os.Build
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadOpenExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import java.io.File
import java.util.UUID

internal class MediaReadSessionFactory(
    private val contentResolver: ContentResolver,
    private val fileLocationResolver: FileLocationResolver,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    val sdkInt: Int = Build.VERSION.SDK_INT
) {
    fun create(request: MediaReadRequest): Result<MediaReadSession> = runCatching {
        if (!isPermissionAvailable()) {
            throw MediaProviderException(
                MediaReadOpenExceptionCodes.PERMISSION_DENIED,
                "The required permissions for reading the media item is not granted"
            )
        }

        val mediaColumn = contentResolver.query(
            request.contentUri.toUri(),
            mediaColumnsReaderFactory.projection.toTypedArray(),
            null, null, null
        )?.use {
            if (!it.moveToFirst()) {
                throw MediaProviderException(
                    MediaReadOpenExceptionCodes.MEDIA_NOT_FOUND,
                    "The requested media item does not seem to exist"
                )
            }

            val reader = mediaColumnsReaderFactory.create(it)
            return@use reader.read()
        } ?: throw MediaProviderException(
            MediaReadOpenExceptionCodes.INVALID_STATE,
            "The media provider is not responding"
        )

        val fileLocation = mediaColumn.data?.let { fileLocationResolver.resolve(it) }
        val backingFile = fileLocation?.absoluteFilePath?.let { File(it) }
        return@runCatching MediaReadSession(
            sessionId = UUID.randomUUID().toString(),
            contentUri = request.contentUri,
            sizeInBytes = mediaColumn.sizeInBytes ?: backingFile?.length(),
            isSeekable = backingFile?.canRead() ?: false
        )
    }

    private fun isPermissionAvailable(): Boolean {
        // TODO: Implement actual logic here
        return true
    }
}