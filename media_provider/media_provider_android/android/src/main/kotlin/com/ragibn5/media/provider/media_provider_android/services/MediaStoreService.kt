package com.ragibn5.media.provider.media_provider_android.services

import com.ragibn5.media.provider.media_provider_android.models.MediaItemData
import com.ragibn5.media.provider.media_provider_android.models.MediaType

internal interface MediaStoreService {
    /**
     * Get all media of [types] managed by the media store.
     *
     * @return An empty list if [types] is empty.
     */
    suspend fun getMedia(types: Set<MediaType>): List<MediaItemData>
}
