package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * The `MediaStore` collection a [MediaItemData] comes from.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal enum class MediaType {
    /**
     * `MediaStore.Images`.
     */
    @SerialName("photo")
    PHOTO,

    /**
     * `MediaStore.Video`.
     */
    @SerialName("video")
    VIDEO,
}
