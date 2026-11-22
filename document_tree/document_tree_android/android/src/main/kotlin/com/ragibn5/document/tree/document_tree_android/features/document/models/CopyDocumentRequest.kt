package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to copy a file into a tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class CopyDocumentRequest(
    /**
     * The file to copy: any URI the app can open for reading, such as a `content://` URI from
     * MediaStore, or a `file://` URI the app can read.
     */
    val sourceUri: String,
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * Where to put the copy, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`.
     * The folder holding it must exist, and nothing must be at it.
     */
    val path: String,
    /**
     * The URI of the folder holding [path], from an earlier result; `null` when it isn't known.
     * Only a shortcut: it's used while that folder exists under the name [path] gives it;
     * otherwise the folder is found by [path].
     */
    val parentUri: String? = null,
    /**
     * The copy's MIME type, or `null` to tell it from [path]'s extension, then from the source.
     */
    val mimeType: String? = null,
    /**
     * The algorithm to hash the copied bytes with, as they're written; `null` for no hash.
     */
    val hashAlgorithm: ContentHashAlgorithm? = null,
)
