package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentQueryExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import com.ragibn5.document.tree.document_tree_android.features.document.models.GetDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Describes single documents in the trees the app holds a grant on.
 */
internal fun interface DocumentGetService {
    /**
     * Describes the document [request] points to.
     *
     * @return the document, or `null` if there's none at its path.
     * @throws DocumentTreeException with a [DocumentQueryExceptionCodes] code.
     */
    suspend fun get(request: GetDocumentRequest): DocumentInfo?
}

internal class DocumentGetServiceImpl(
    private val grants: PersistedTreeGrants,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentGetService {
    override suspend fun get(request: GetDocumentRequest): DocumentInfo? = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        val grant = grants.find(treeUri)
            ?: throw DocumentTreeException(
                DocumentQueryExceptionCodes.ACCESS_LOST,
                "The app holds no grant on the tree: ${request.treeUri}"
            )

        val row = if (request.path.isEmpty()) {
            rowReader.readDocument(treeUri, DocumentsContract.getTreeDocumentId(treeUri))
        } else {
            pathResolver.findDocument(treeUri, request.path, request.parentUri)?.row
        }

        return@withContext row?.toInfo(treeUri, request.path, grant.isWritePermission)
    }
}
