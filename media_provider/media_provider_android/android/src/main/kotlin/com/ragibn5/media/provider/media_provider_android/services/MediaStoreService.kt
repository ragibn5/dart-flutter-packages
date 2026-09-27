package com.ragibn5.media.provider.media_provider_android.services

import com.ragibn5.media.provider.media_provider_android.models.MediaItemData

interface MediaStoreService {
    /**
     * Get all photos managed by the media store.
     */
    fun getPhotos(): List<MediaItemData>

    /**
     * Get all videos managed by the media store.
     */
    fun getVideos(): List<MediaItemData>
}