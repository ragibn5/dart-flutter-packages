package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.app.Activity
import android.content.Context
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaChooserLauncher
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaMimeTypeResolver
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenMediaWithService
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenMediaWithServiceImpl

internal object OpenMediaWithServiceFactory {
    fun create(context: Context, currentActivity: () -> Activity?): OpenMediaWithService {
        return OpenMediaWithServiceImpl(
            chooserLauncher = MediaChooserLauncher(currentActivity),
            mimeTypeResolver = MediaMimeTypeResolver(context.contentResolver),
        )
    }
}
