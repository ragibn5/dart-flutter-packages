package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to create a folder in a tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class CreateDirectoryRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The folder to create, relative to the tree's root, such as `DCIM/Archive`. The folder
     * holding it must exist.
     */
    val path: String,
)
