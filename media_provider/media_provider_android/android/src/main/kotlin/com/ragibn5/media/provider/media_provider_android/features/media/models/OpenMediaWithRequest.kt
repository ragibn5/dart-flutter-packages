package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to open a `MediaStore` item in another app.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenMediaWithRequest(
    /** The `content://` URI of the item to open. */
    val contentUri: String,
    /** The title of the app chooser, or `null` for the system's default. */
    val chooserTitle: String? = null,
)
