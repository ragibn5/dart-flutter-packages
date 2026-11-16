package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.net.Uri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

/**
 * Checks that the app may write into a tree, before anything in it is changed.
 */
internal class WritableGrantVerifier(private val grants: PersistedTreeGrants) {
    /**
     * Returns if the app holds a grant on [treeUri] that allows writing.
     *
     * @throws DocumentTreeException with [DocumentWriteExceptionCodes.ACCESS_LOST] if it holds
     * none, or [DocumentWriteExceptionCodes.NOT_WRITABLE] if its grant only allows reading.
     */
    fun verify(treeUri: Uri) {
        val grant = grants.find(treeUri)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.ACCESS_LOST,
                "The app holds no grant on the tree: $treeUri"
            )
        if (!grant.isWritePermission) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_WRITABLE,
                "The app's grant on the tree doesn't allow writing: $treeUri"
            )
        }
    }
}
