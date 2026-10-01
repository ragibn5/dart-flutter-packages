package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import java.io.File
import java.util.Locale

internal class FileLocationResolver(
    val appContext: Context
) {
    fun resolve(file: File): FileLocation? {
        val storageManager = appContext.getSystemService(StorageManager::class.java)
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = file.getStorageVolumePath()?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null

        return FileLocation(
            volumeName = volume.getStorageVolumeName(),
            relativeParentPath = fileParentPath.substring(volumePath.length),
            fileNameWithExtension = file.name
        )
    }

    private fun StorageVolume.getStorageVolumeName(): String? {
        return if (isPrimary) null else uuid?.lowercase(Locale.US)
    }

    private fun File.getStorageVolumePath(): String? {
        val volumePathResolver = VolumePathResolver(appContext)
        return volumePathResolver.resolve(this)
    }

    private fun String.ensureTrailingSlash(): String {
        return if (this.endsWith("/")) this else "$this/"
    }
}