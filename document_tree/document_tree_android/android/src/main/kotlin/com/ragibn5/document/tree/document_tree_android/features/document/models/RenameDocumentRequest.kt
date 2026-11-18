package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to rename a document in its folder.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class RenameDocumentRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The document, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`.
     */
    val path: String,
    /**
     * The document's new name, such as `IMG_1.jpg`; not a path.
     */
    val newName: String,
)
