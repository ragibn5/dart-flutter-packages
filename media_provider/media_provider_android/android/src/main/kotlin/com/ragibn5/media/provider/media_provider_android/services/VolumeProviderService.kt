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
        return VolumeProviderServiceImpl(storageManager)
    }
}

internal class VolumeProviderServiceImpl(
    private val storageManager: StorageManager,
    private val volumeTypeResolver: VolumeTypeResolver = VolumeTypeResolver,
) : VolumeProviderService {
    override fun getVolumes(): List<VolumeInfo> {
        return storageManager.storageVolumes.map {
            VolumeInfo(
                state = VolumeState.from(it.state),
                identity = VolumeIdentity(
                    isPrimary = it.isPrimary,
                    isRemovable = it.isRemovable,
                    isEmulated = it.isEmulated,
                    uuid = it.uuid,
                    type = volumeTypeResolver.resolve(it),
                ),
            )
        }
    }
}