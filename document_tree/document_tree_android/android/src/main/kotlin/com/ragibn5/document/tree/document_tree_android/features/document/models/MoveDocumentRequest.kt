package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to move a document to another folder in its tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MoveDocumentRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The document, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`.
     */
    val path: String,
    /**
     * The folder to move it into, relative to the tree's root, such as `DCIM/Archive`;
     * empty for the root. It must exist.
     */
    val newParentPath: String,
)
