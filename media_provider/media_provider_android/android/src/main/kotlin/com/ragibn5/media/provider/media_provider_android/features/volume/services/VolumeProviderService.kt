package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
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
        return storageManager.storageVolumes.mapNotNull { volume ->
            val path = volumePathResolver.resolve(volume) ?: return@mapNotNull null
            val stats = fileStatsResolver.resolve(path)
            return@mapNotNull VolumeInfo(
                state = VolumeState.from(volume.state),
                availableSpaceInBytes = stats?.availableSpaceInBytes,
                identity = VolumeIdentity(
                    uuid = volume.uuid,
                    type = volumeTypeResolver.resolve(volume),
                    volumePath = path.ensureNoTrailingSlash(),
                    capacityInBytes = stats?.capacityInBytes,
                    isPrimary = volume.isPrimary,
                    isRemovable = volume.isRemovable,
                    isEmulated = volume.isEmulated,
                ),
            )
        }
    }
}