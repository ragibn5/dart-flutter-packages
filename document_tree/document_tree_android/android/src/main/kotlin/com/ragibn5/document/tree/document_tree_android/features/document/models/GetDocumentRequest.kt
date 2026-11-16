package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to describe one document in a tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class GetDocumentRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The document, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`; empty for the
     * root.
     */
    val path: String,
)
