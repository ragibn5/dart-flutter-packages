package com.ragibn5.document.tree.document_tree_android.features.tree.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to let the user pick a document tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class PickTreeRequest(
    /**
     * The URI the picker starts at, such as the current tree's, or `null` for
     * the system's default. Ignored below Android 8.0 (API 26).
     */
    val initialUri: String? = null,
)
