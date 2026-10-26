package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to share `MediaStore` items with another app.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class ShareMediaRequest(
    /** The `content://` URIs of the items to share; at least one. */
    val contentUris: List<String>,
    /** The title of the share chooser, or `null` for the system's default. */
    val chooserTitle: String? = null,
)
