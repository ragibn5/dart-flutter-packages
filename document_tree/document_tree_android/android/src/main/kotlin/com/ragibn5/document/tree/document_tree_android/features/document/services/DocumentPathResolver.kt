package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.net.Uri
import android.provider.DocumentsContract
import android.util.Log
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentAccessExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder
import com.ragibn5.document.tree.document_tree_android.features.document.models.LocatedDocument

/**
 * Finds folders in a tree by their path, one segment at a time from its root, or straight from
 * a known folder URI that still matches the path.
 *
 * Blocks while the provider is asked; must be called off the main thread.
 */
internal class DocumentPathResolver(private val rowReader: DocumentRowReader) {
    /**
     * The folder at the normalized [path] in [treeUri], or `null` if there's none.
     *
     * [folderUri], when given, is that folder's URI from an earlier result: it's used if the
     * folder it names still matches [path], and [path] is walked otherwise.
     *
     * @throws DocumentTreeException with a [DocumentAccessExceptionCodes] code.
     */
    fun findFolder(treeUri: Uri, path: String, folderUri: String? = null): DocumentFolder? {
        if (folderUri != null) {
            findKnownFolder(treeUri, path, folderUri)?.let { return it }
        }

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
     * [folderUri], when given, is the URI of the folder holding it, used as [findFolder] does.
     *
     * @throws DocumentTreeException with a [DocumentAccessExceptionCodes] code.
     */
    fun findDocument(treeUri: Uri, path: String, folderUri: String? = null): LocatedDocument? {
        val folder = findFolder(treeUri, DocumentPaths.parent(path), folderUri) ?: return null
        val name = DocumentPaths.name(path)
        val row = rowReader.readChildren(treeUri, folder.documentId)
            .firstOrNull { it.displayName == name }
            ?: return null
        return LocatedDocument(folder, row)
    }

    /**
     * The folder [folderUri] names, if it's in [treeUri] and still at [path]: the tree's root
     * for an empty [path], otherwise a folder with [path]'s last name. `null` otherwise, or if it
     * can't be read, so the caller walks [path] instead.
     */
    private fun findKnownFolder(treeUri: Uri, path: String, folderUri: String): DocumentFolder? {
        val documentId = try {
            DocumentsContract.getDocumentId(folderUri.toUri())
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Not a document URI, so walking $path: $folderUri", e)
            return null
        }

        if (path.isEmpty()) {
            return root(treeUri).takeIf { it.documentId == documentId }
        }

        val row = try {
            rowReader.readDocument(treeUri, documentId)
        } catch (e: DocumentTreeException) {
            // Gone, or not in the tree: walking finds out what's at the path now.
            Log.w(TAG, "Can't read the known folder, so walking $path: $folderUri", e)
            return null
        }
        if (!row.isDirectory || row.displayName != DocumentPaths.name(path)) {
            return null
        }
        return DocumentFolder(documentId, path)
    }

    private fun root(treeUri: Uri) = DocumentFolder(DocumentsContract.getTreeDocumentId(treeUri), path = "")

    private companion object {
        private const val TAG = "DocumentPathResolver"
    }
}
