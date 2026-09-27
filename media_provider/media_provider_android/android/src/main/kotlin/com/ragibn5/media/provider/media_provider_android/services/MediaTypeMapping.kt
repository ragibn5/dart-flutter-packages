package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.provider.MediaStore
import android.provider.MediaStore.Files.FileColumns
import com.ragibn5.media.provider.media_provider_android.models.MediaType

/**
 * The `FileColumns.MEDIA_TYPE` value of this type's rows in `MediaStore.Files`.
 */
internal val MediaType.mediaStoreType: Int
    get() = when (this) {
        MediaType.PHOTO -> FileColumns.MEDIA_TYPE_IMAGE
        MediaType.VIDEO -> FileColumns.MEDIA_TYPE_VIDEO
    }

/**
 * The type-specific collection this type's items belong to.
 */
internal val MediaType.collectionUri: Uri
    get() = when (this) {
        MediaType.PHOTO -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        MediaType.VIDEO -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
    }

/**
 * The [MediaType] whose [mediaStoreType] is [mediaStoreType], or `null` if
 * the plugin doesn't support it.
 */
internal fun mediaTypeOf(mediaStoreType: Int): MediaType? =
    MediaType.entries.find { it.mediaStoreType == mediaStoreType }
