package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import java.io.File

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
    private val volumeTypeResolver: VolumeTypeResolver = VolumeTypeResolver(),
    private val fileStatsResolver: FileStatsResolver = FileStatsResolver(),
) {
    fun resolve(path: String): FileLocation? {
        val file = File(path)
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
        val stats = fileStatsResolver.resolve(volumePath)
        return VolumeIdentity(
            uuid = uuid,
            type = volumeTypeResolver.resolve(this),
            volumePath = volumePath.ensureNoTrailingSlash(),
            capacityInBytes = stats?.capacityInBytes ?: 0,
            isPrimary = isPrimary,
            isRemovable = isRemovable,
            isEmulated = isEmulated,
        )
    }
}