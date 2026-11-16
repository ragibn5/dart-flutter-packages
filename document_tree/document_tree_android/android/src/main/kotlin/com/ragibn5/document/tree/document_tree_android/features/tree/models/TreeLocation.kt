package com.ragibn5.document.tree.document_tree_android.features.tree.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * Where a tree is on the device's storage.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class TreeLocation(
    /**
     * `primary` for the primary shared storage, or the volume's filesystem UUID.
     */
    val volumeId: String,
    /**
     * The tree's folder, relative to the volume's root; empty for the root itself.
     */
    val relativePath: String,
)
