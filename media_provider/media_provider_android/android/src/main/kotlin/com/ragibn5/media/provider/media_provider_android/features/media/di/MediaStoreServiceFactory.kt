package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaItemUriBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreServiceImpl
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumePathResolver

internal object MediaStoreServiceFactory {
    fun create(context: Context): MediaStoreService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val uriBuilder = MediaItemUriBuilder
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        val fileLocationResolver =
            FileLocationResolver(
                storageManager = storageManager,
                volumePathResolver = volumePathResolver,
            )
        return MediaStoreServiceImpl(
            contentResolver = context.contentResolver,
            queryBuilder = MediaQueryBuilder(
                storageManager = storageManager,
                volumePathResolver = volumePathResolver,
            ),
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(
                fileLocationResolver = fileLocationResolver,
                uriBuilder = uriBuilder,
                sdkInt = sdkInt
            ),
        )
    }
}