package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.util.Log
import com.ragibn5.document.tree.document_tree_android.features.tree.models.DocumentTree

/**
 * Describes the trees the app holds a grant on.
 */
internal class DocumentTreeResolver(
    private val contentResolver: ContentResolver,
    private val grants: PersistedTreeGrants,
    private val locationResolver: TreeLocationResolver,
) {
    /**
     * Describes [treeUri], or returns `null` if the app holds no grant on it,
     * or it can't be reached, such as when it was deleted or its volume was
     * removed.
     *
     * Blocks while the provider is asked; must be called off the main thread.
     */
    fun resolve(treeUri: Uri): DocumentTree? {
        val grant = grants.find(treeUri) ?: return null
        val root = queryRoot(treeUri) ?: return null

        return DocumentTree(
            uri = treeUri.toString(),
            displayName = root.displayName,
            canWrite = grant.isWritePermission && root.flags and Document.FLAG_DIR_SUPPORTS_CREATE != 0,
            location = locationResolver.resolve(treeUri),
            grantedAtInMillis = grant.persistedTime,
            lastModifiedInMillis = root.lastModifiedInMillis,
        )
    }

    private fun queryRoot(treeUri: Uri): Root? {
        val rootUri = DocumentsContract.buildDocumentUriUsingTree(
            treeUri,
            DocumentsContract.getTreeDocumentId(treeUri),
        )
        return try {
            contentResolver.query(rootUri, PROJECTION, null, null, null)?.use { cursor ->
                if (!cursor.moveToFirst()) return null
                Root(
                    displayName = cursor.getString(cursor.getColumnIndexOrThrow(Document.COLUMN_DISPLAY_NAME)),
                    flags = cursor.getInt(cursor.getColumnIndexOrThrow(Document.COLUMN_FLAGS)),
                    lastModifiedInMillis = cursor.getColumnIndexOrThrow(Document.COLUMN_LAST_MODIFIED)
                        .let { if (cursor.isNull(it)) null else cursor.getLong(it) },
                )
            }
        } catch (e: IllegalArgumentException) {
            // The provider no longer knows the document.
            Log.w(TAG, "Failed to query the root of $treeUri", e)
            null
        } catch (e: SecurityException) {
            // The grant no longer covers it.
            Log.w(TAG, "Failed to query the root of $treeUri", e)
            null
        }
    }

    private class Root(val displayName: String, val flags: Int, val lastModifiedInMillis: Long?)

    private companion object {
        private const val TAG = "DocumentTreeResolver"

        private val PROJECTION = arrayOf(
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_FLAGS,
            Document.COLUMN_LAST_MODIFIED,
        )
    }
}
