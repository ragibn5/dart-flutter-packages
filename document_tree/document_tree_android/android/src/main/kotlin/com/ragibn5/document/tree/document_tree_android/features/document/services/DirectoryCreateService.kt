package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.provider.DocumentsContract.Document
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDirectoryRequest
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Creates folders in the trees the app holds a grant on.
 */
internal fun interface DirectoryCreateService {
    /**
     * Creates the folder [request] points to, in the existing folder holding it.
     *
     * @return the created folder.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun create(request: CreateDirectoryRequest): DocumentInfo
}

internal class DirectoryCreateServiceImpl(
    private val grantVerifier: WritableGrantVerifier,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val creator: DocumentCreator,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DirectoryCreateService {
    override suspend fun create(request: CreateDirectoryRequest): DocumentInfo = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        grantVerifier.verify(treeUri)

        val parentPath = DocumentPaths.parent(request.path)
        val parent = pathResolver.findFolder(treeUri, parentPath, request.parentUri)
            ?: throw DocumentTreeException(
                DocumentWriteExceptionCodes.NOT_FOUND,
                "No folder is at: $parentPath"
            )
        val name = DocumentPaths.name(request.path)
        if (rowReader.readChildren(treeUri, parent.documentId).any { it.displayName == name }) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.ALREADY_EXISTS,
                "A document is already at: ${request.path}"
            )
        }

        val folder = creator.create(treeUri, parent, Document.MIME_TYPE_DIR, name)
        return@withContext folder.toInfo(treeUri, request.path, grantAllowsWriting = true)
    }
}
