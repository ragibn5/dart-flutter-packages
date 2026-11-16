package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.net.Uri
import android.provider.DocumentsContract
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentAccessExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder
import com.ragibn5.document.tree.document_tree_android.features.document.models.LocatedDocument

/**
 * Finds folders in a tree by their path, one segment at a time from its root.
 *
 * Blocks while the provider is asked; must be called off the main thread.
 */
internal class DocumentPathResolver(private val rowReader: DocumentRowReader) {
    /**
     * The folder at the normalized [path] in [treeUri], or `null` if there's none.
     *
     * @throws DocumentTreeException with a [DocumentAccessExceptionCodes] code.
     */
    fun findFolder(treeUri: Uri, path: String): DocumentFolder? {
        var folder = root(treeUri)
        for (segment in DocumentPaths.segments(path)) {
            val child = rowReader.readChildren(treeUri, folder.documentId)
                .firstOrNull { it.displayName == segment && it.isDirectory }
                ?: return null
            folder = DocumentFolder(child.documentId, DocumentPaths.child(folder.path, segment))
        }
        return folder
    }

    /**
     * The document at the normalized, non-empty [path] in [treeUri], with the folder holding
     * it, or `null` if there's none.
     *
     * @throws DocumentTreeException with a [DocumentAccessExceptionCodes] code.
     */
    fun findDocument(treeUri: Uri, path: String): LocatedDocument? {
        val folder = findFolder(treeUri, DocumentPaths.parent(path)) ?: return null
        val name = DocumentPaths.name(path)
        val row = rowReader.readChildren(treeUri, folder.documentId)
            .firstOrNull { it.displayName == name }
            ?: return null
        return LocatedDocument(folder, row)
    }

    private fun root(treeUri: Uri) = DocumentFolder(DocumentsContract.getTreeDocumentId(treeUri), path = "")
}
