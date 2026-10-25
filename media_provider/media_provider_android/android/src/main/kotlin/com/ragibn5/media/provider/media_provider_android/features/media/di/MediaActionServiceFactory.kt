package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.app.Activity
import android.content.Context
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaActionService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaActionServiceImpl

internal object MediaActionServiceFactory {
    fun create(context: Context, currentActivity: () -> Activity?): MediaActionService {
        return MediaActionServiceImpl(
            contentResolver = context.contentResolver,
            currentActivity = currentActivity,
        )
    }
}
