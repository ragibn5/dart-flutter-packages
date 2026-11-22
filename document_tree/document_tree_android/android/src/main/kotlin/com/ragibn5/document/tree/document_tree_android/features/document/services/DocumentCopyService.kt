package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.document.constants.DocumentWriteExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.document.models.ContentHash
import com.ragibn5.document.tree.document_tree_android.features.document.models.CopiedDocument
import com.ragibn5.document.tree.document_tree_android.features.document.models.CopyDocumentRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import java.io.FileNotFoundException
import java.io.InputStream
import java.io.OutputStream
import java.security.MessageDigest

/**
 * Copies files into the trees the app holds a grant on.
 */
internal fun interface DocumentCopyService {
    /**
     * Copies the file [request] points to into its tree, as a new file in an existing folder.
     *
     * Note:
     * - The copy is deleted again if it fails or is cancelled, so it leaves nothing behind.
     * - With [CopyDocumentRequest.hashAlgorithm], the bytes are hashed as they're written, so
     *   the hash is of exactly what the copy holds, with no second read.
     *
     * @return the copy, and its content's hash if one was asked for.
     * @throws DocumentTreeException with a [DocumentWriteExceptionCodes] code.
     */
    suspend fun copy(request: CopyDocumentRequest): CopiedDocument
}

internal class DocumentCopyServiceImpl(
    private val contentResolver: ContentResolver,
    private val grantVerifier: WritableGrantVerifier,
    private val rowReader: DocumentRowReader,
    private val pathResolver: DocumentPathResolver,
    private val creator: DocumentCreator,
    private val mimeTypeResolver: DocumentMimeTypeResolver,
    private val contentWriter: DocumentContentWriter,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentCopyService {
    override suspend fun copy(request: CopyDocumentRequest): CopiedDocument = withContext(ioDispatcher) {
        val treeUri = request.treeUri.toUri()
        grantVerifier.verify(treeUri)

        val sourceUri = request.sourceUri.toUri()
        val fileName = DocumentPaths.name(request.path)
        val parentPath = DocumentPaths.parent(request.path)
        val folder = pathResolver.findFolder(treeUri, parentPath, request.parentUri)
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

        val hashing = request.hashAlgorithm?.let { it to MessageDigest.getInstance(it.digestName) }
        // Opened before anything is created, so a missing source leaves no trace.
        val document = openSource(sourceUri).use { input ->
            val target = creator.create(
                treeUri = treeUri,
                parent = folder,
                mimeType = mimeTypeResolver.resolve(request.mimeType, fileName, sourceUri),
                displayName = fileName,
            )
            try {
                contentWriter.write(treeUri, target, request.path) { copyBytes(input, it, hashing?.second) }
            } catch (e: Throwable) {
                creator.delete(treeUri, target.documentId)
                throw e
            }
            target
        }

        val info = rowReader.readDocument(treeUri, document.documentId)
            .toInfo(treeUri, request.path, grantAllowsWriting = true)
        val contentHash = hashing?.let { (algorithm, digest) ->
            ContentHash(algorithm, digest.digest().toHex())
        }
        return@withContext CopiedDocument(info, contentHash)
    }

    private fun openSource(sourceUri: Uri): InputStream {
        return try {
            contentResolver.openInputStream(sourceUri)
        } catch (e: FileNotFoundException) {
            throw sourceNotFound(sourceUri, e)
        } catch (e: SecurityException) {
            throw DocumentTreeException(
                DocumentWriteExceptionCodes.SOURCE_PERMISSION_DENIED,
                e.message ?: "The app can't read the source: $sourceUri",
                cause = e
            )
        } ?: throw sourceNotFound(sourceUri)
    }

    /**
     * Copies every byte of [input] into [output], feeding each into [digest] too when given.
     */
    private suspend fun copyBytes(input: InputStream, output: OutputStream, digest: MessageDigest?) {
        val buffer = ByteArray(BUFFER_SIZE_IN_BYTES)
        while (true) {
            currentCoroutineContext().ensureActive()
            val count = input.read(buffer)
            if (count < 0) {
                return
            }
            output.write(buffer, 0, count)
            digest?.update(buffer, 0, count)
        }
    }

    private fun ByteArray.toHex(): String = joinToString(separator = "") { "%02x".format(it) }

    private fun sourceNotFound(sourceUri: Uri, cause: Throwable? = null) = DocumentTreeException(
        DocumentWriteExceptionCodes.SOURCE_NOT_FOUND,
        cause?.message ?: "The source can't be opened: $sourceUri",
        cause = cause
    )

    private companion object {
        private const val BUFFER_SIZE_IN_BYTES = 256 * 1024
    }
}
