package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaCollectionUriResolver
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaItemUriBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryBuilder
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaSourceOpener
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreServiceImpl
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumePathResolver
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService

internal object MediaStoreServiceFactory {
    fun create(context: Context, volumeProviderService: VolumeProviderService): MediaStoreService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val storageManager = context.getSystemService(StorageManager::class.java)
        val contentResolver = context.contentResolver
        val collectionUriResolver = MediaCollectionUriResolver.DEFAULT
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        val fileLocationResolver = FileLocationResolver(volumeProviderService)
        val mediaColumnsReaderFactory = MediaColumnsReaderFactory(sdkInt = sdkInt)
        return MediaStoreServiceImpl(
            contentResolver = contentResolver,
            fileLocationResolver = fileLocationResolver,
            mediaQueryBuilder = MediaQueryBuilder(
                storageManager,
                volumePathResolver,
                collectionUriResolver
            ),
            mediaItemUriBuilder = MediaItemUriBuilder,
            mediaColumnsReaderFactory = mediaColumnsReaderFactory,
            mediaSourceOpener = MediaSourceOpener(contentResolver),
        )
    }
}