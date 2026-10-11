package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.models.VolumeState

internal interface VolumeProviderService {
    fun getVolumes(): List<VolumeInfo>
}

internal object VolumeProviderServiceFactory {
    fun create(context: Context): VolumeProviderService {
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumePathResolver = VolumePathResolver(context, storageManager)
        return VolumeProviderServiceImpl(storageManager, volumePathResolver)
    }
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