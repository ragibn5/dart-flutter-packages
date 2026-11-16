package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentAccessExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow

/**
 * Reads documents in a tree, as their provider reports them.
 *
 * Blocks while the provider is asked; must be called off the main thread.
 */
internal class DocumentRowReader(private val contentResolver: ContentResolver) {
    /**
     * The children of the folder [parentDocumentId] in [treeUri].
     *
     * @throws DocumentTreeException with
     * [DocumentAccessExceptionCodes.TREE_UNAVAILABLE] if the folder can't be
     * read, or [DocumentAccessExceptionCodes.ACCESS_LOST] if the grant no
     * longer covers it.
     */
    fun readChildren(treeUri: Uri, parentDocumentId: String): List<DocumentRow> {
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocumentId)
        return query(childrenUri).use { cursor ->
            val columns = Columns(cursor)
            buildList {
                while (cursor.moveToNext()) {
                    add(columns.read(cursor))
                }
            }
        }
    }

    /**
     * The document [documentId] in [treeUri].
     *
     * @throws DocumentTreeException with
     * [DocumentAccessExceptionCodes.TREE_UNAVAILABLE] if the document can't
     * be read, or [DocumentAccessExceptionCodes.ACCESS_LOST] if the grant no
     * longer covers it.
     */
    fun readDocument(treeUri: Uri, documentId: String): DocumentRow {
        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)
        return query(documentUri).use { cursor ->
            if (!cursor.moveToFirst()) {
                throw unavailable()
            }
            Columns(cursor).read(cursor)
        }
    }

    private fun query(uri: Uri): Cursor {
        return try {
            contentResolver.query(uri, PROJECTION, null, null, null)
        } catch (e: IllegalArgumentException) {
            throw unavailable(e)
        } catch (e: SecurityException) {
            throw DocumentTreeException(
                DocumentAccessExceptionCodes.ACCESS_LOST,
                e.message ?: "The grant no longer covers the tree",
                cause = e
            )
        } ?: throw unavailable()
    }

    private fun unavailable(cause: Throwable? = null) = DocumentTreeException(
        DocumentAccessExceptionCodes.TREE_UNAVAILABLE,
        "The document can't be read; the tree may be deleted, or its volume removed",
        cause = cause
    )

    private class Columns(cursor: Cursor) {
        private val id = cursor.getColumnIndexOrThrow(Document.COLUMN_DOCUMENT_ID)
        private val name = cursor.getColumnIndexOrThrow(Document.COLUMN_DISPLAY_NAME)
        private val mimeType = cursor.getColumnIndexOrThrow(Document.COLUMN_MIME_TYPE)
        private val flags = cursor.getColumnIndexOrThrow(Document.COLUMN_FLAGS)
        private val size = cursor.getColumnIndexOrThrow(Document.COLUMN_SIZE)
        private val lastModified = cursor.getColumnIndexOrThrow(Document.COLUMN_LAST_MODIFIED)

        fun read(cursor: Cursor) = DocumentRow(
            documentId = cursor.getString(id),
            displayName = cursor.getString(name),
            mimeType = cursor.getString(mimeType),
            flags = cursor.getInt(flags),
            sizeInBytes = if (cursor.isNull(size)) null else cursor.getLong(size),
            lastModifiedInMillis = if (cursor.isNull(lastModified)) null else cursor.getLong(lastModified),
        )
    }

    private companion object {
        private val PROJECTION = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_FLAGS,
            Document.COLUMN_SIZE,
            Document.COLUMN_LAST_MODIFIED,
        )
    }
}
