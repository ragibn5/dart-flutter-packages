package com.ragibn5.document.tree.document_tree_android.features.document.services

import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.CreateDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentInfo
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Creates files in the trees the app holds a grant on.
 */
internal fun interface DocumentCreateService {
    /**
     * Creates the file [request] points to, in the existing folder holding it, with [bytes] as
     * its content, or empty if `null`.
     *
     * Note:
     * The file is deleted again if writing [bytes] fails, so it leaves nothing behind.
     *
     * @return the created file.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun create(request: CreateDocumentRequest, bytes: ByteArray?): DocumentInfo
}

internal class DocumentCreateServiceImpl(
    private val grantVerifier: WritableGrantVerifier,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val creator: DocumentCreator,
    private val mimeTypeResolver: DocumentMimeTypeResolver,
    private val contentWriter: DocumentContentWriter,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentCreateService {
    override suspend fun create(request: CreateDocumentRequest, bytes: ByteArray?): DocumentInfo =
        withContext(ioDispatcher) {
            val treeUri = request.treeUri.toUri()
            grantVerifier.verify(treeUri)

            val fileName = DocumentPaths.name(request.path)
            val parentPath = DocumentPaths.parent(request.path)
            val folder = pathResolver.findFolder(treeUri, parentPath)
                ?: throw DocumentTreeException(
                    DocumentWriteExceptionCodes.NOT_FOUND,
                    "No folder is at: $parentPath"
                )
            if (rowReader.readChildren(treeUri, folder.documentId).any { it.displayName == fileName }) {
                throw DocumentTreeException(
                    DocumentWriteExceptionCodes.ALREADY_EXISTS,
                    "A document is already at: ${request.path}"
                )
            }

            val document = creator.create(
                treeUri = treeUri,
                parent = folder,
                mimeType = mimeTypeResolver.resolve(request.mimeType, fileName, sourceUri = null),
                displayName = fileName,
            )
            if (bytes != null) {
                try {
                    contentWriter.write(treeUri, document, request.path) { it.write(bytes) }
                } catch (e: Throwable) {
                    creator.delete(treeUri, document.documentId)
                    throw e
                }
            }

            return@withContext rowReader.readDocument(treeUri, document.documentId)
                .toInfo(treeUri, request.path, grantAllowsWriting = true)
        }
}
