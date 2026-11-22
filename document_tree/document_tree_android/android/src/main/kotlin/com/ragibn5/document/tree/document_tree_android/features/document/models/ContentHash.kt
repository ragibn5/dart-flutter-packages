package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * The hash of some content.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class ContentHash(
    /** The algorithm it's made with. */
    val algorithm: ContentHashAlgorithm,
    /** The hash, in lowercase hexadecimal. */
    val value: String,
)
