package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaType

/**
 * Describes a MediaStore collection supported by the plugin.
 */
internal interface MediaStoreCollection {
    val type: MediaType
    val uri: Uri
}

internal object PhotoMediaStoreCollection : MediaStoreCollection {
    override val type = MediaType.PHOTO
    override val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
}

internal object VideoMediaStoreCollection : MediaStoreCollection {
    override val type = MediaType.VIDEO
    override val uri: Uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
}

internal class MediaStoreCollectionRegistry(
    collections: Set<MediaStoreCollection>,
) {
    private val collectionsByType = collections.associateBy { it.type }

    init {
        require(collectionsByType.size == collections.size) {
            "Multiple MediaStore collections are registered for the same MediaType."
        }
    }

    fun get(type: MediaType): MediaStoreCollection =
        collectionsByType.getValue(type)
}
