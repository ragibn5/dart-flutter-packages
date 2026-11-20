package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import com.ragibn5.document.tree.document_tree_android.features.document.models.MoveDocumentRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Moves documents between folders of the trees the app holds a grant on.
 */
internal fun interface DocumentMoveService {
    /**
     * Moves the document [request] points to into another existing folder of its tree, keeping
     * its name.
     *
     * Note:
     * Whether the name is taken in the new folder is the provider's call, by its own rules, such
     * as a filesystem that ignores case.
     *
     * @return the moved document.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun move(request: MoveDocumentRequest): DocumentInfo
}

internal class DocumentMoveServiceImpl(
    private val contentResolver: ContentResolver,
    private val grantVerifier: WritableGrantVerifier,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentMoveService {
    override suspend fun move(request: MoveDocumentRequest): DocumentInfo = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        grantVerifier.verify(treeUri)

        val document = pathResolver.findDocument(treeUri, request.path, request.parentUri)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_FOUND,
                "No document is at: ${request.path}"
            )
        val name = document.row.displayName
        val newPath = DocumentPaths.child(request.newParentPath, name)
        if (document.folder.path == request.newParentPath) {
            return@withContext document.row.toInfo(treeUri, newPath, grantAllowsWriting = true)
        }
        if (document.row.flags and Document.FLAG_SUPPORTS_MOVE == 0) {
            throw DocumentProviderCalls.unsupported("move", request.path)
        }

        val newParent = pathResolver.findFolder(treeUri, request.newParentPath, request.newParentUri)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_FOUND,
                "No folder is at: ${request.newParentPath}"
            )
        // Checked here so it fails clearly, unless the caller knows the name is free; the provider
        // fails the move for clashes by its rules.
        if (!request.skipNameCheck && isNameTaken(treeUri, newParent.documentId, name)) {
            throw alreadyExists(newPath)
        }

        val movedUri = try {
            DocumentProviderCalls.run("move", request.path) {
                DocumentsContract.moveDocument(
                    contentResolver,
                    DocumentsContract.buildDocumentUriUsingTree(treeUri, document.row.documentId),
                    DocumentsContract.buildDocumentUriUsingTree(treeUri, document.folder.documentId),
                    DocumentsContract.buildDocumentUriUsingTree(treeUri, newParent.documentId),
                )
            }
        } catch (e: DocumentTreeException) {
            // Unchecked before, so a failure may be a taken name: report it as one.
            if (request.skipNameCheck && isNameTaken(treeUri, newParent.documentId, name)) {
                throw alreadyExists(newPath, cause = e)
            }
            throw e
        }
        val moved = rowReader.readDocument(treeUri, DocumentsContract.getDocumentId(movedUri))

        return@withContext moved.toInfo(
            treeUri,
            DocumentPaths.child(request.newParentPath, moved.displayName),
            grantAllowsWriting = true,
        )
    }

    /**
     * Whether a document named [name] is in the folder [folderId] of [treeUri].
     */
    private fun isNameTaken(treeUri: Uri, folderId: String, name: String): Boolean {
        return rowReader.readChildren(treeUri, folderId).any { it.displayName == name }
    }

    private fun alreadyExists(path: String, cause: Throwable? = null) = DocumentTreeException(
        DocumentWriteExceptionCodes.ALREADY_EXISTS,
        "A document is already at: $path",
        cause = cause,
    )
}
