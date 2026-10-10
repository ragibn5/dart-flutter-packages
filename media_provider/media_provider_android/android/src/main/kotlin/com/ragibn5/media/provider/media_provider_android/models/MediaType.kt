package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * The `MediaStore` collection a [MediaItem] comes from.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal enum class MediaType {
    /**
     * `MediaStore.Images`.
     */
    PHOTO,

    /**
     * `MediaStore.Video`.
     */
    VIDEO,
}
