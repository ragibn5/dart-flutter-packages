package com.ragibn5.content.io.content_io_android.features.hash.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * Asks for the hash of the content behind [uri].
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class HashContentRequest(
    /** The `content://` URI of the content to hash. */
    val uri: String,
    /** The algorithm to hash it with. */
    val algorithm: ContentHashAlgorithm,
)
