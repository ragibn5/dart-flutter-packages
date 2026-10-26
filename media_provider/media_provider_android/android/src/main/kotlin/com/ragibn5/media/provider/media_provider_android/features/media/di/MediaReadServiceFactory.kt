package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.content.Context
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadServiceImpl
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaSourceOpener

internal object MediaReadServiceFactory {
    fun create(context: Context): MediaReadService {
        return MediaReadServiceImpl(
            mediaSourceOpener = MediaSourceOpener(context.contentResolver),
        )
    }
}
