package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to delete a document: a file, or a folder with everything in it.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class DeleteDocumentRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The document, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`.
     */
    val path: String,
)
