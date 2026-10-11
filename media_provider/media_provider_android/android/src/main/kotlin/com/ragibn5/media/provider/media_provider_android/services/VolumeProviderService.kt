package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.StatFs
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
        return VolumeProviderServiceImpl(
            storageManager,
            volumePathResolver,
            VolumeTypeResolver(),
        )
    }
}

internal class VolumeProviderServiceImpl(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
    private val volumeTypeResolver: VolumeTypeResolver,
) : VolumeProviderService {
    override fun getVolumes(): List<VolumeInfo> {
        return storageManager.storageVolumes.map {
            val stats = StatFs(volumePathResolver.resolve(it))
            VolumeInfo(
                state = VolumeState.from(it.state),
                availableSpaceInBytes = stats.availableBytes,
                identity = VolumeIdentity(
                    isPrimary = it.isPrimary,
                    isRemovable = it.isRemovable,
                    isEmulated = it.isEmulated,
                    uuid = it.uuid,
                    capacityInBytes = stats.totalBytes,
                    type = volumeTypeResolver.resolve(it),
                ),
            )
        }
    }
}