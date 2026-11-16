package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to list the documents in a folder of a tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class ListDocumentsRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The folder to list, relative to the tree's root, such as `DCIM/Camera`; empty for the root.
     */
    val path: String = "",
    /**
     * Whether to list the folder's subfolders too, all the way down.
     */
    val recursive: Boolean = false,
)
