package com.ragibn5.media.provider.media_provider_android.services

import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import java.io.File

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
) {
    fun resolve(file: File): FileLocation? {
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = volumePathResolver.resolve(volume)?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        return FileLocation(
            volumeInfo = VolumeInfo(volume.isPrimary, volume.uuid),
            relativeParentPath = fileParentPath.substring(volumePath.length),
            fileNameWithExtension = file.name
        )
    }
}
