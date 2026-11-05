package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.content.Intent
import android.net.Uri
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.tree.constants.TreePickExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.tree.models.DocumentTree
import com.ragibn5.document.tree.document_tree_android.features.tree.models.PickTreeRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Gives the app persistent access to folders the user picks.
 */
internal interface DocumentTreeService {
    /**
     * Lets the user pick a folder, and persists the app's access to it.
     *
     * Must be called on the main thread.
     *
     * @return the picked tree, or `null` if the user cancelled.
     * @throws DocumentTreeException with a [TreePickExceptionCodes] code.
     */
    suspend fun pick(request: PickTreeRequest): DocumentTree?

    /**
     * Describes [treeUri], or returns `null` if the app holds no grant on it,
     * or it can't be reached.
     */
    suspend fun get(treeUri: Uri): DocumentTree?

    /**
     * Drops the app's access to [treeUri]; does nothing if it has none.
     */
    suspend fun release(treeUri: Uri)
}

internal class DocumentTreeServiceImpl(
    private val pickerLauncher: TreePickerLauncher,
    private val grants: PersistedTreeGrants,
    private val treeResolver: DocumentTreeResolver,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) : DocumentTreeService {
    override suspend fun pick(request: PickTreeRequest): DocumentTree? {
        val result = pickerLauncher.launch(request.initialUri?.toUri()) ?: return null
        val treeUri = result.data ?: return null

        // Persist only what the picker granted.
        val modeFlags = result.flags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)

        return withContext(ioDispatcher) {
            grants.take(treeUri, modeFlags)
            treeResolver.resolve(treeUri)
        }
    }

    override suspend fun get(treeUri: Uri): DocumentTree? = withContext(ioDispatcher) {
        treeResolver.resolve(treeUri)
    }

    override suspend fun release(treeUri: Uri) = withContext(ioDispatcher) {
        grants.release(treeUri)
    }
}
