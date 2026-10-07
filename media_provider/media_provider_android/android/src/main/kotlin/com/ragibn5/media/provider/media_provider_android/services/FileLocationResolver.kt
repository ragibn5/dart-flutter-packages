package com.ragibn5.media.provider.media_provider_android.services

import android.annotation.SuppressLint
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import java.io.File
import java.util.Locale

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    fun resolve(file: File): FileLocation? {
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = volumePathResolver.resolve(file)?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        return FileLocation(
            volumeName = volume.getStorageVolumeName(),
            relativeParentPath = fileParentPath.substring(volumePath.length),
            fileNameWithExtension = file.name
        )
    }

    private fun StorageVolume.getStorageVolumeName(): String? {
        return if (sdkInt >= Build.VERSION_CODES.R) {
            @SuppressLint("NewApi")
            mediaStoreVolumeName
        } else {
            @SuppressLint("InlinedApi")
            if (isPrimary) MediaStore.VOLUME_EXTERNAL_PRIMARY else normalizeUuid(uuid)
        }
    }

    /**
     * This is a fallback workaround.
     * Make sure to check this if your target android sdk version changes.
     * */
    private fun normalizeUuid(fsUuid: String?): String? {
        return fsUuid?.lowercase(Locale.US)
    }
}
