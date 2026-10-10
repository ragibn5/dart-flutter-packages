package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaType

internal class MediaCollectionUriResolver(
    private val photoCollection: () -> Uri,
    private val videoCollection: () -> Uri,
) {
    fun collectionFor(type: MediaType): Uri = when (type) {
        MediaType.PHOTO -> photoCollection()
        MediaType.VIDEO -> videoCollection()
    }

    companion object {
        val DEFAULT: MediaCollectionUriResolver = MediaCollectionUriResolver(
            photoCollection = { MediaStore.Images.Media.EXTERNAL_CONTENT_URI },
            videoCollection = { MediaStore.Video.Media.EXTERNAL_CONTENT_URI },
        )
    }
}