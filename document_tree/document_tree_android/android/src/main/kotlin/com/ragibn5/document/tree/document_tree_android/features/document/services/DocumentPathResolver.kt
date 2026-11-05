package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentAccessExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder

/**
 * Finds folders in a tree by their path, one segment at a time from its root.
 *
 * Blocks while the provider is asked; must be called off the main thread.
 */
internal class DocumentPathResolver(
    private val rowReader: DocumentRowReader,
    private val creator: DocumentCreator,
) {
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
     * The folder at the normalized [path] in [treeUri], creating the missing ones on the way.
     *
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code;
     * [DocumentWriteExceptionCodes.ALREADY_EXISTS] if a file is where a folder should be.
     */
    fun findOrCreateFolder(treeUri: Uri, path: String): DocumentFolder {
        var folder = root(treeUri)
        for (segment in DocumentPaths.segments(path)) {
            val children = rowReader.readChildren(treeUri, folder.documentId)
            val child = children.firstOrNull { it.displayName == segment }
                ?: creator.create(treeUri, folder, children, Document.MIME_TYPE_DIR, segment)
            val childPath = DocumentPaths.child(folder.path, segment)
            if (!child.isDirectory) {
                throw DocumentTreeException(
                    DocumentWriteExceptionCodes.ALREADY_EXISTS,
                    "A file is where a folder should be: $childPath"
                )
            }
            folder = DocumentFolder(child.documentId, childPath)
        }
        return folder
    }

    private fun root(treeUri: Uri) = DocumentFolder(DocumentsContract.getTreeDocumentId(treeUri), path = "")
}
