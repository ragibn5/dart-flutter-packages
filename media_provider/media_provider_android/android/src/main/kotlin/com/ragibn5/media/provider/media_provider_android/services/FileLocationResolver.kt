package com.ragibn5.media.provider.media_provider_android.services

import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.util.Log
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import java.io.File
import java.util.Locale

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
) {
    fun resolve(file: File): FileLocation? {
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = volumePathResolver.resolve(file)?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        val relativeParentPath = fileParentPath.substring(volumePath.length)
        Log.d("AAA", "$volume --- $volumePath --- $fileParentPath --- $relativeParentPath")
        return FileLocation(
            volumeName = volume.getStorageVolumeName(),
            relativeParentPath = relativeParentPath,
            fileNameWithExtension = file.name
        )
    }

    private fun StorageVolume.getStorageVolumeName(): String? {
        return if (isPrimary) null else uuid?.lowercase(Locale.US)
    }
}