package com.ragibn5.media.provider.media_provider_android.features.volume.di

import android.content.Context
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumePathResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderServiceImpl

internal object VolumeProviderServiceFactory {
    fun create(context: Context): VolumeProviderService {
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumePathResolver = VolumePathResolver(context, storageManager)
        return VolumeProviderServiceImpl(storageManager, volumePathResolver)
    }
}
