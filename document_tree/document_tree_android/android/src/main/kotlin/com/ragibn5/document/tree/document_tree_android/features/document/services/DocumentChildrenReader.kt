package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow

/**
 * Reads the children of a folder in a tree.
 */
internal class DocumentChildrenReader(private val contentResolver: ContentResolver) {
    /**
     * The children of the folder [parentDocumentId] in [treeUri].
     *
     * Blocks while the provider is asked; must be called off the main thread.
     *
     * @throws DocumentTreeException with
     * [DocumentQueryExceptionCodes.TREE_UNAVAILABLE] if the folder can't be
     * read, or [DocumentQueryExceptionCodes.ACCESS_LOST] if the grant no
     * longer covers it.
     */
    fun read(treeUri: Uri, parentDocumentId: String): List<DocumentRow> {
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocumentId)
        val cursor = try {
            contentResolver.query(childrenUri, PROJECTION, null, null, null)
        } catch (e: IllegalArgumentException) {
            throw unavailable(e)
        } catch (e: SecurityException) {
            throw DocumentTreeException(
                DocumentQueryExceptionCodes.ACCESS_LOST,
                e.message ?: "The grant no longer covers the tree",
                cause = e
            )
        } ?: throw unavailable()

        return cursor.use {
            val idColumn = it.getColumnIndexOrThrow(Document.COLUMN_DOCUMENT_ID)
            val nameColumn = it.getColumnIndexOrThrow(Document.COLUMN_DISPLAY_NAME)
            val mimeTypeColumn = it.getColumnIndexOrThrow(Document.COLUMN_MIME_TYPE)
            val flagsColumn = it.getColumnIndexOrThrow(Document.COLUMN_FLAGS)
            val sizeColumn = it.getColumnIndexOrThrow(Document.COLUMN_SIZE)
            val lastModifiedColumn = it.getColumnIndexOrThrow(Document.COLUMN_LAST_MODIFIED)

            buildList {
                while (it.moveToNext()) {
                    add(
                        DocumentRow(
                            documentId = it.getString(idColumn),
                            displayName = it.getString(nameColumn),
                            mimeType = it.getString(mimeTypeColumn),
                            flags = it.getInt(flagsColumn),
                            sizeInBytes = if (it.isNull(sizeColumn)) null else it.getLong(sizeColumn),
                            lastModifiedInMillis = if (it.isNull(lastModifiedColumn)) null else it.getLong(lastModifiedColumn),
                        )
                    )
                }
            }
        }
    }

    private fun unavailable(cause: Throwable? = null) = DocumentTreeException(
        DocumentQueryExceptionCodes.TREE_UNAVAILABLE,
        "The folder can't be read; the tree may be deleted, or its volume removed",
        cause = cause
    )

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
