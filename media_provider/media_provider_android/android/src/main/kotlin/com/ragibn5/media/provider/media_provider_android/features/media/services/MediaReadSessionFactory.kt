package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.Context
import android.os.Build
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadOpenExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import java.io.FileNotFoundException
import java.io.InputStream
import java.util.UUID

internal class MediaReadSessionFactory(
    val appContext: Context,
    val sdkInt: Int = Build.VERSION.SDK_INT
) {
    fun create(request: MediaReadRequest): Result<MediaReadSession> = runCatching {
        if (!isPermissionAvailable()) {
            throw MediaProviderException(
                MediaReadOpenExceptionCodes.PERMISSION_DENIED,
                "The required permission for reading the media item is not granted"
            )
        }

        var inputStream: InputStream? = null
        try {
            inputStream =
                appContext.contentResolver.openInputStream(request.contentUri.toUri())
            if (inputStream == null) {
                throw MediaProviderException(
                    MediaReadOpenExceptionCodes.INVALID_STATE,
                    "The media provider is not responding"
                )
            }

            val uuid = UUID.randomUUID().toString()
            return@runCatching MediaReadSession(uuid, request.contentUri)
        } catch (_: FileNotFoundException) {
            throw MediaProviderException(
                MediaReadOpenExceptionCodes.MEDIA_NOT_FOUND,
                "The requested media item does not seem to exist"
            )
        } catch (e: Exception) {
            // TMP: Remove after debugging
            e.printStackTrace()
            throw e
        } finally {
            inputStream?.close()
        }
    }

    private fun isPermissionAvailable(): Boolean {
        // TODO: Implement actual logic here
        return true
    }
}