package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to read the thumbnail of a `MediaStore` item.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenThumbnailReadRequest(
    /** The `content://` URI of the item whose thumbnail to read. */
    val contentUri: String,
    /** The size to request the thumbnail at. */
    val size: ThumbnailSize,
)
