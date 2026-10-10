package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo

internal interface VolumesInfoProviderService {
    fun getVolumes(): List<VolumeInfo>
}

internal object VolumesInfoProviderServiceFactory {
    fun create(context: Context): VolumesInfoProviderService {
        val storageManager = context.getSystemService(StorageManager::class.java)
        return VolumesInfoProviderServiceImpl(storageManager)
    }
}

internal class VolumesInfoProviderServiceImpl(
    private val storageManager: StorageManager
) : VolumesInfoProviderService {
    override fun getVolumes(): List<VolumeInfo> {
        return storageManager.storageVolumes.map { VolumeInfo(it.isPrimary, it.uuid) }
    }
}