package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.system.ErrnoException
import android.system.OsConstants
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow
import java.io.IOException
import java.io.OutputStream

/**
 * Writes the content of new documents in a tree.
 *
 * Blocks while writing; must be called off the main thread.
 */
internal class DocumentContentWriter(private val contentResolver: ContentResolver) {
    /**
     * Opens the new, empty [target], at [path] in [treeUri], for writing, and lets [write] write
     * into it.
     *
     * Note:
     * The stream is closed before this returns; closing can fail too, such as when the volume
     * fills up while flushing.
     *
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun write(
        treeUri: Uri,
        target: DocumentRow,
        path: String,
        write: suspend (OutputStream) -> Unit,
    ) {
        val targetUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, target.documentId)
        try {
            val output = try {
                contentResolver.openOutputStream(targetUri, "w")
            } catch (e: SecurityException) {
                throw DocumentTreeException(
                    DocumentWriteExceptionCodes.ACCESS_LOST,
                    e.message ?: "The grant no longer covers the tree",
                    cause = e
                )
            } ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.WRITE_ERROR,
                "The provider couldn't open the document for writing: $path"
            )
            output.use { write(it) }
        } catch (e: IOException) {
            throw writeFailed(path, e)
        }
    }

    private fun writeFailed(path: String, cause: IOException): DocumentTreeException {
        val isOutOfSpace = generateSequence<Throwable>(cause) { it.cause }.any {
            (it is ErrnoException && it.errno == OsConstants.ENOSPC) || it.message?.contains("ENOSPC") == true
        }
        return if (isOutOfSpace) {
            DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_ENOUGH_SPACE,
                "The volume ran out of space while writing to: $path",
                cause = cause
            )
        } else {
            DocumentTreeException(
                DocumentWriteExceptionCodes.WRITE_ERROR,
                cause.message ?: "Failed to write to: $path",
                cause = cause
            )
        }
    }
}
