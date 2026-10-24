package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaCollectionUriResolver
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaItemUriBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryServiceImpl
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumePathResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService

internal object MediaQueryServiceFactory {
    fun create(context: Context, volumeProviderService: VolumeProviderService): MediaQueryService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val storageManager = context.getSystemService(StorageManager::class.java)
        val collectionUriResolver = MediaCollectionUriResolver.DEFAULT
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        return MediaQueryServiceImpl(
            contentResolver = context.contentResolver,
            fileLocationResolver = FileLocationResolver(volumeProviderService),
            mediaQueryBuilder = MediaQueryBuilder(
                storageManager,
                volumePathResolver,
                collectionUriResolver
            ),
            mediaItemUriBuilder = MediaItemUriBuilder,
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(sdkInt = sdkInt),
        )
    }
}
