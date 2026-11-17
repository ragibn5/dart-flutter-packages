package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to create a file in a tree.
 *
 * Note:
 * The file's content, if any, comes with the request but outside it, as raw bytes.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class CreateDocumentRequest(
    /**
     * The tree's URI.
     */
    val treeUri: String,
    /**
     * The file to create, relative to the tree's root, such as `.intellisync/mirror-0001.json`.
     * The folder holding it must exist, and nothing must be at it.
     */
    val path: String,
    /**
     * The file's MIME type, or `null` to tell it from [path]'s extension.
     */
    val mimeType: String? = null,
)
