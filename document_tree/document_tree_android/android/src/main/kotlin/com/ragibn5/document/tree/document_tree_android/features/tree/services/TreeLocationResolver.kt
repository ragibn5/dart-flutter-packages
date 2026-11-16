package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.net.Uri
import android.provider.DocumentsContract
import com.ragibn5.document.tree.document_tree_android.features.tree.models.TreeLocation

/**
 * Resolves where a tree is on the device's storage.
 */
internal class TreeLocationResolver {
    /**
     * The location of [treeUri], or `null` when its provider isn't the
     * device's storage.
     *
     * Note:
     * The storage provider's document IDs are `<volume id>:<relative path>`,
     * such as `B63B-1E04:IntelliSync` or `primary:DCIM`.
     */
    fun resolve(treeUri: Uri): TreeLocation? {
        if (treeUri.authority != EXTERNAL_STORAGE_AUTHORITY) {
            return null
        }

        val documentId = DocumentsContract.getTreeDocumentId(treeUri)
        val volumeId = documentId.substringBefore(':', missingDelimiterValue = "")
        if (volumeId.isEmpty()) {
            return null
        }

        return TreeLocation(volumeId = volumeId, relativePath = documentId.substringAfter(':'))
    }

    private companion object {
        private const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"
    }
}
