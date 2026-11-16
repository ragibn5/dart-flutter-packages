package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A file or folder in a tree.
 *
 * Note:
 * Always readable: the tree's grant covers everything in it, and a listing
 * fails as a whole if the tree can't be read. Whether it can be written to
 * varies; see [canWrite].
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class DocumentInfo(
    /**
     * The document's URI, within the tree's grant.
     */
    val uri: String,
    /**
     * Where it is, relative to the tree's root, such as `DCIM/Camera/IMG_1.jpg`.
     */
    val path: String,
    /**
     * Its name, as its provider shows it.
     */
    val displayName: String,
    /**
     * Whether it's a folder.
     */
    val isDirectory: Boolean,
    /**
     * Whether the grant allows writing, and the document accepts it: a file can be overwritten,
     * or a folder can take new documents.
     */
    val canWrite: Boolean,
    /**
     * Its MIME type, such as `image/jpeg`; folders have `vnd.android.document/directory`.
     */
    val mimeType: String,
    /**
     * Its size in bytes, or `null` for folders, or when its provider doesn't tell.
     */
    val sizeInBytes: Long?,
    /**
     * When it was last modified, in milliseconds since the epoch, or `null` if its provider
     * doesn't tell.
     */
    val lastModifiedInMillis: Long?,
)
