package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver

internal object MediaStoreServiceFactory {
    fun create(contentResolver: ContentResolver): MediaStoreService =
        MediaStoreServiceImpl(contentResolver)
}