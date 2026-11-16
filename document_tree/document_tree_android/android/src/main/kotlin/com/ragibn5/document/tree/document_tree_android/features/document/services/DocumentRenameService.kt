package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.util.Log
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import com.ragibn5.document.tree.document_tree_android.features.document.models.RenameDocumentRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Renames documents in the trees the app holds a grant on.
 */
internal fun interface DocumentRenameService {
    /**
     * Renames the document [request] points to, in its folder.
     *
     * Note:
     * Whether a name is taken is the provider's call, by its own rules, such as a filesystem
     * that ignores case. A provider that picks another name than asked, such as `IMG_1 (1).jpg`
     * for a taken one, gets the document renamed back, and the rename fails.
     *
     * @return the renamed document.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun rename(request: RenameDocumentRequest): DocumentInfo
}

internal class DocumentRenameServiceImpl(
    private val contentResolver: ContentResolver,
    private val grantVerifier: WritableGrantVerifier,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentRenameService {
    override suspend fun rename(request: RenameDocumentRequest): DocumentInfo = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        grantVerifier.verify(treeUri)

        val document = pathResolver.findDocument(treeUri, request.path)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_FOUND,
                "No document is at: ${request.path}"
            )
        val newPath = DocumentPaths.child(document.folder.path, request.newName)
        if (document.row.displayName == request.newName) {
            return@withContext document.row.toInfo(treeUri, newPath, grantAllowsWriting = true)
        }
        if (document.row.flags and Document.FLAG_SUPPORTS_RENAME == 0) {
            throw DocumentProviderCalls.unsupported("rename", request.path)
        }

        // Checked here so it fails clearly, as a provider may pick a free name instead.
        val isNameTaken = rowReader.readChildren(treeUri, document.folder.documentId)
            .any { it.displayName == request.newName }
        if (isNameTaken) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.ALREADY_EXISTS,
                "A document is already at: $newPath"
            )
        }

        val documentUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, document.row.documentId)
        val renamedUri = DocumentProviderCalls.run("rename", request.path) {
            DocumentsContract.renameDocument(contentResolver, documentUri, request.newName)
        }
        val renamed = rowReader.readDocument(treeUri, DocumentsContract.getDocumentId(renamedUri))
        if (renamed.displayName != request.newName) {
            renameBack(renamedUri, document.row.displayName)
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.WRITE_ERROR,
                "The provider named the document `${renamed.displayName}` instead, such as when " +
                    "the name is taken by its rules, or has characters it doesn't allow: $newPath"
            )
        }

        return@withContext renamed.toInfo(treeUri, newPath, grantAllowsWriting = true)
    }

    /**
     * Renames the document [documentUri] back to [originalName], logging a failure instead of
     * throwing it: it only ever cleans up after another failure, which is what the caller reports.
     */
    private fun renameBack(documentUri: Uri, originalName: String) {
        try {
            DocumentsContract.renameDocument(contentResolver, documentUri, originalName)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to rename $documentUri back to $originalName", e)
        }
    }

    private companion object {
        private const val TAG = "DocumentRenameService"
    }
}
