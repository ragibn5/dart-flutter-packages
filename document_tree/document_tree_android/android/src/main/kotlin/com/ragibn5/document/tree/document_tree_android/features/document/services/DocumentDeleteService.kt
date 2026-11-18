package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DeleteDocumentRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Deletes documents in the trees the app holds a grant on.
 */
internal fun interface DocumentDeleteService {
    /**
     * Deletes the document [request] points to: a file, or a folder with everything in it.
     *
     * Note:
     * A folder's deletion that fails partway may leave some of what it held.
     *
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun delete(request: DeleteDocumentRequest)
}

internal class DocumentDeleteServiceImpl(
    private val contentResolver: ContentResolver,
    private val grantVerifier: WritableGrantVerifier,
    private val pathResolver: DocumentPathResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentDeleteService {
    override suspend fun delete(request: DeleteDocumentRequest) = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        grantVerifier.verify(treeUri)

        val document = pathResolver.findDocument(treeUri, request.path)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_FOUND,
                "No document is at: ${request.path}"
            )
        if (document.row.flags and Document.FLAG_SUPPORTS_DELETE == 0) {
            throw DocumentProviderCalls.unsupported("deletion", request.path)
        }

        DocumentProviderCalls.run("deletion", request.path) {
            DocumentsContract.deleteDocument(
                contentResolver,
                DocumentsContract.buildDocumentUriUsingTree(treeUri, document.row.documentId),
            )
        }
        return@withContext
    }
}
