package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.provider.DocumentsContract.Document

/**
 * A document in a folder, as its provider reports it.
 */
internal data class DocumentRow(
    val documentId: String,
    val displayName: String,
    val mimeType: String,
    val flags: Int,
    val sizeInBytes: Long?,
    val lastModifiedInMillis: Long?,
) {
    val isDirectory: Boolean get() = mimeType == Document.MIME_TYPE_DIR

    /**
     * Whether the document accepts writing: a file can be overwritten, or a folder can take new
     * documents.
     */
    val acceptsWriting: Boolean
        get() = flags and (if (isDirectory) Document.FLAG_DIR_SUPPORTS_CREATE else Document.FLAG_SUPPORTS_WRITE) != 0
}
