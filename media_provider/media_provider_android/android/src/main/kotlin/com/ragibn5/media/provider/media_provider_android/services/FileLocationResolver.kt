package com.ragibn5.media.provider.media_provider_android.services

import android.os.StatFs
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.models.VolumeIdentity
import java.io.File

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
    private val volumeTypeResolver: VolumeTypeResolver,
) {
    fun resolve(file: File): FileLocation? {
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = volumePathResolver.resolve(volume)?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        return FileLocation(
            volumeIdentity = volume.toVolumeIdentity(volumePath),
            relativeParentPath = fileParentPath.substring(volumePath.length),
            fileNameWithExtension = file.name
        )
    }

    private fun StorageVolume.toVolumeIdentity(volumePath: String): VolumeIdentity {
        val volumeStats = StatFs(volumePath)
        return VolumeIdentity(
            isPrimary = isPrimary,
            isRemovable = isRemovable,
            isEmulated = isEmulated,
            uuid = uuid,
            capacityInBytes = volumeStats.totalBytes,
            type = volumeTypeResolver.resolve(this),
        )
    }
}