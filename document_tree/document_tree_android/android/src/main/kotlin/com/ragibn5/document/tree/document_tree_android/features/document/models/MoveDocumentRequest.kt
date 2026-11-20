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
    /**
     * The URI of the folder holding [path], from an earlier result; `null` when it isn't known.
     * Only a shortcut: it's used while that folder exists under the name [path] gives it;
     * otherwise the folder is found by [path].
     */
    val parentUri: String? = null,
    /**
     * The URI of the folder [newParentPath] names, from an earlier result; `null` when it isn't
     * known. Only a shortcut: it's used while that folder exists under the name [newParentPath]
     * gives it; otherwise the folder is found by [newParentPath].
     */
    val newParentUri: String? = null,
    /**
     * Whether to move without first checking that no document in [newParentPath] has the name.
     * Set only when the name is known to be free; otherwise what happens is the provider's call:
     * Android's local storage fails the move, but another provider may replace the document
     * already there.
     */
    val skipNameCheck: Boolean = false,
)
