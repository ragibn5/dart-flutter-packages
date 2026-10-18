package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeState


internal interface VolumeProviderService {
    fun getVolumes(): List<VolumeInfo>
}

internal class VolumeProviderServiceImpl(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
    private val volumeTypeResolver: VolumeTypeResolver = VolumeTypeResolver(),
    private val fileStatsResolver: FileStatsResolver = FileStatsResolver(),
) : VolumeProviderService {
    override fun getVolumes(): List<VolumeInfo> {
        return storageManager.storageVolumes.map { volume ->
            val path = volumePathResolver.resolve(volume)
            val stats = path?.let { fileStatsResolver.resolve(path) }
            VolumeInfo(
                state = VolumeState.from(volume.state),
                availableSpaceInBytes = stats?.availableSpaceInBytes ?: 0,
                identity = VolumeIdentity(
                    isPrimary = volume.isPrimary,
                    isRemovable = volume.isRemovable,
                    isEmulated = volume.isEmulated,
                    uuid = volume.uuid,
                    capacityInBytes = stats?.capacityInBytes ?: 0,
                    type = volumeTypeResolver.resolve(volume),
                ),
            )
        }
    }
}