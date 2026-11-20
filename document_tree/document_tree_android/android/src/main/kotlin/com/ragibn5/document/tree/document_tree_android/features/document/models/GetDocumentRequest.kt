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
    /**
     * The URI of the folder holding [path], from an earlier result; `null` when it isn't known.
     * Only a shortcut: it's used while that folder exists under the name [path] gives it;
     * otherwise the folder is found by [path]. Unused when [path] is empty.
     */
    val parentUri: String? = null,
)
