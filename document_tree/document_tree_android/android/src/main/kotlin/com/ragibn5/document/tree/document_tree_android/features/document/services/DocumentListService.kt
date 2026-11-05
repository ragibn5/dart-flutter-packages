package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow
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
    private val childrenReader: DocumentChildrenReader,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentListService {
    override suspend fun list(request: ListDocumentsRequest): List<DocumentInfo> = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        val grant = grants.find(treeUri)
            ?: throw DocumentTreeException(
                DocumentQueryExceptionCodes.ACCESS_LOST,
                "The app holds no grant on the tree: ${request.treeUri}"
            )

        // Breadth first, from the requested folder down.
        val documents = mutableListOf<DocumentInfo>()
        val pendingFolders = ArrayDeque(listOf(resolveFolder(treeUri, request.path)))
        while (pendingFolders.isNotEmpty()) {
            val folder = pendingFolders.removeFirst()
            for (row in childrenReader.read(treeUri, folder.documentId)) {
                val path = childPath(folder.path, row.displayName)
                documents += row.toInfo(treeUri, path, grant.isWritePermission)
                if (request.recursive && row.isDirectory) {
                    pendingFolders += Folder(row.documentId, path)
                }
            }
        }

        return@withContext documents
    }

    /**
     * Finds the folder at [path], one segment at a time from the tree's root.
     */
    private fun resolveFolder(treeUri: Uri, path: String): Folder {
        var folder = Folder(DocumentsContract.getTreeDocumentId(treeUri), path = "")
        if (path.isEmpty()) {
            return folder
        }

        for (segment in path.split('/')) {
            val child = childrenReader.read(treeUri, folder.documentId)
                .firstOrNull { it.displayName == segment && it.isDirectory }
                ?: throw DocumentTreeException(
                    DocumentQueryExceptionCodes.NOT_FOUND,
                    "No folder at: $path"
                )
            folder = Folder(child.documentId, childPath(folder.path, segment))
        }
        return folder
    }

    private fun childPath(parentPath: String, name: String) =
        if (parentPath.isEmpty()) name else "$parentPath/$name"

    private fun DocumentRow.toInfo(treeUri: Uri, path: String, grantAllowsWriting: Boolean) = DocumentInfo(
        uri = DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId).toString(),
        path = path,
        displayName = displayName,
        isDirectory = isDirectory,
        canWrite = grantAllowsWriting && acceptsWriting,
        mimeType = mimeType,
        // A folder's size means different things to different providers.
        sizeInBytes = if (isDirectory) null else sizeInBytes,
        lastModifiedInMillis = lastModifiedInMillis,
    )

    private class Folder(val documentId: String, val path: String)
}
