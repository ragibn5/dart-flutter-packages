package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.content.ContentResolver
import android.content.Intent
import android.content.UriPermission
import android.net.Uri

/**
 * The persisted grants the app holds on document trees.
 */
internal class PersistedTreeGrants(private val contentResolver: ContentResolver) {
    /**
     * The grant on [treeUri], or `null` if the app holds none.
     */
    fun find(treeUri: Uri): UriPermission? {
        return contentResolver.persistedUriPermissions.firstOrNull { it.uri == treeUri }
    }

    /**
     * Persists the grant the picker gave on [treeUri], with its [modeFlags].
     */
    fun take(treeUri: Uri, modeFlags: Int) {
        contentResolver.takePersistableUriPermission(treeUri, modeFlags)
    }

    /**
     * Drops the grant on [treeUri]; does nothing if the app holds none.
     */
    fun release(treeUri: Uri) {
        val grant = find(treeUri) ?: return

        var modeFlags = 0
        if (grant.isReadPermission) modeFlags = modeFlags or Intent.FLAG_GRANT_READ_URI_PERMISSION
        if (grant.isWritePermission) modeFlags = modeFlags or Intent.FLAG_GRANT_WRITE_URI_PERMISSION

        try {
            contentResolver.releasePersistableUriPermission(treeUri, modeFlags)
        } catch (_: SecurityException) {
            // Released meanwhile; there's nothing left to release.
        }
    }
}
