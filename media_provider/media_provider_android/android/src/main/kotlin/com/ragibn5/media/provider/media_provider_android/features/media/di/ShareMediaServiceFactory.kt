package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.app.Activity
import android.content.Context
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaChooserLauncher
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaMimeTypeResolver
import com.ragibn5.media.provider.media_provider_android.features.media.services.ShareMediaService
import com.ragibn5.media.provider.media_provider_android.features.media.services.ShareMediaServiceImpl

internal object ShareMediaServiceFactory {
    fun create(context: Context, currentActivity: () -> Activity?): ShareMediaService {
        return ShareMediaServiceImpl(
            chooserLauncher = MediaChooserLauncher(currentActivity),
            mimeTypeResolver = MediaMimeTypeResolver(context.contentResolver),
        )
    }
}
