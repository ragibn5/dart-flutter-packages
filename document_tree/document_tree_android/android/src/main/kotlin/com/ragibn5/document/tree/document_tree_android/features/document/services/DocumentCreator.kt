package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.util.Log
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow
import java.io.FileNotFoundException

/**
 * Creates and deletes documents in a tree.
 *
 * Blocks while the provider is asked; must be called off the main thread.
 */
internal class DocumentCreator(
    private val contentResolver: ContentResolver,
    private val rowReader: DocumentRowReader,
) {
    /**
     * Creates a document named [displayName] in [parent].
     *
     * Note:
     * A provider may name the document differently than asked: it renames it when the name is
     * taken by its rules, such as a filesystem that ignores case, and may add an extension that
     * matches [mimeType]. Such a document is deleted again, and the creation fails, so a
     * document is never written under a name the caller didn't ask for.
     *
     * @param mimeType its MIME type; `vnd.android.document/directory` for a folder.
     * @return the created document.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    fun create(
        treeUri: Uri,
        parent: DocumentFolder,
        mimeType: String,
        displayName: String,
    ): DocumentRow {
        val parentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, parent.documentId)
        val documentUri = try {
            DocumentsContract.createDocument(contentResolver, parentUri, mimeType, displayName)
        } catch (e: SecurityException) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.ACCESS_LOST,
                e.message ?: "The grant no longer covers the tree",
                cause = e
            )
        } catch (e: FileNotFoundException) {
            throw creationFailed(displayName, parent, e)
        } catch (e: IllegalArgumentException) {
            throw creationFailed(displayName, parent, e)
        } catch (e: IllegalStateException) {
            throw creationFailed(displayName, parent, e)
        } ?: throw creationFailed(displayName, parent)

        val documentId = DocumentsContract.getDocumentId(documentUri)
        val row = try {
            rowReader.readDocument(treeUri, documentId)
        } catch (e: DocumentTreeException) {
            delete(treeUri, documentId)
            throw e
        }
        if (row.displayName == displayName) {
            return row
        }

        delete(treeUri, row.documentId)
        throw DocumentTreeException(
            DocumentWriteExceptionCodes.WRITE_ERROR,
            "The provider named the document `${row.displayName}` instead, such as when the " +
                "name is taken by its rules, or its extension doesn't match the MIME type " +
                "`$mimeType`: ${DocumentPaths.child(parent.path, displayName)}"
        )
    }

    /**
     * Deletes the document [documentId] in [treeUri], logging a failure instead of throwing it:
     * it only ever cleans up after another failure, which is what the caller reports.
     */
    fun delete(treeUri: Uri, documentId: String) {
        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)
        try {
            if (!DocumentsContract.deleteDocument(contentResolver, documentUri)) {
                Log.w(TAG, "Failed to delete $documentUri")
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to delete $documentUri", e)
        }
    }

    private fun creationFailed(displayName: String, parent: DocumentFolder, cause: Throwable? = null) =
        DocumentTreeException(
            DocumentWriteExceptionCodes.WRITE_ERROR,
            cause?.message ?: "The provider couldn't create: ${DocumentPaths.child(parent.path, displayName)}",
            cause = cause
        )

    private companion object {
        private const val TAG = "DocumentCreator"
    }
}
