package com.ragibn5.document.tree.document_tree_android.features.document.services

import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import com.ragibn5.document.tree.document_tree_android.features.document.models.ListDocumentsRequest
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Lists the documents in the trees the app holds a grant on.
 */
internal fun interface DocumentListService {
    /**
     * Lists the documents in the folder [request] points to.
     *
     * @throws DocumentTreeException with a [DocumentQueryExceptionCodes] code.
     */
    suspend fun list(request: ListDocumentsRequest): List<DocumentInfo>
}

internal class DocumentListServiceImpl(
    private val grants: PersistedTreeGrants,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentListService {
    override suspend fun list(request: ListDocumentsRequest): List<DocumentInfo> = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        val grant = grants.find(treeUri)
            ?: throw DocumentTreeException(
                DocumentQueryExceptionCodes.ACCESS_LOST,
                "The app holds no grant on the tree: ${request.treeUri}"
            )
        val folder = pathResolver.findFolder(treeUri, request.path)
            ?: throw DocumentTreeException(
                DocumentQueryExceptionCodes.NOT_FOUND,
                "No folder at: ${request.path}"
            )

        // Breadth first, from the requested folder down.
        val documents = mutableListOf<DocumentInfo>()
        val pendingFolders = ArrayDeque(listOf(folder))
        while (pendingFolders.isNotEmpty()) {
            val parent = pendingFolders.removeFirst()
            for (row in rowReader.readChildren(treeUri, parent.documentId)) {
                val path = DocumentPaths.child(parent.path, row.displayName)
                documents += row.toInfo(treeUri, path, grant.isWritePermission)
                if (request.recursive && row.isDirectory) {
                    pendingFolders += DocumentFolder(row.documentId, path)
                }
            }
        }

        return@withContext documents
    }
}
