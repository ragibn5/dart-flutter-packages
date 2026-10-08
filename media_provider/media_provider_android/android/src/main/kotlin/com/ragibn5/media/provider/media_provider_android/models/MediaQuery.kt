package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A query describing the media to fetch from the `MediaStore`.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaQuery(
    /**
     * The media types to include in the query result.
     *
     * If null or empty, empty results will be returned.
     */
    val types: Set<MediaType>? = null,

    /**
     * The storage volumes to search.
     *
     * If null or empty, no volume based filtration is done and the result may
     * include media from all the available storage volumes on the device.
     */
    val volumes: Set<StorageVolumeSpec>? = null,
)