package com.ragibn5.document.tree.document_tree_android.features.tree.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A folder the user granted the app persistent access to.
 *
 * Note:
 * Always readable: a tree that can't be read is reported as unavailable, not
 * returned. Whether it can be written to varies; see [canWrite].
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class DocumentTree(
    /**
     * The tree's URI, such as `content://com.android.externalstorage.documents/tree/B63B-1E04%3AIntelliSync`.
     *  */
    val uri: String,
    /**
     * The folder's name, as its provider shows it.
     */
    val displayName: String,
    /**
     * Whether the grant allows writing, and the folder accepts new documents.
     */
    val canWrite: Boolean,
    /**
     * Where the tree is on the device's storage, or `null` when that can't be confirmed: its
     * provider isn't the device's storage, such as a cloud drive, or the system doesn't know the
     * folder.
     */
    val location: TreeLocation?,
    /**
     * When the user granted the app access, in milliseconds since the epoch.
     */
    val grantedAtInMillis: Long,
    /**
     * When the folder was last modified, in milliseconds since the epoch, or `null` if its provider
     * doesn't tell.
     */
    val lastModifiedInMillis: Long?,
)
