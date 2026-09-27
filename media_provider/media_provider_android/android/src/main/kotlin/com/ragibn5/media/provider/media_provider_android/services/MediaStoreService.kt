package com.ragibn5.media.provider.media_provider_android.services

import com.ragibn5.media.provider.media_provider_android.models.MediaItemData

internal interface MediaStoreService {
    /**
     * Get all photos managed by the media store.
     */
    suspend fun getPhotos(): List<MediaItemData>
}