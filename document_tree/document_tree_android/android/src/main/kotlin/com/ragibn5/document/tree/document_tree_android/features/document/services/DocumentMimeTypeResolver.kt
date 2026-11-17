package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.webkit.MimeTypeMap

/**
 * Tells the MIME type to create a file with.
 */
internal class DocumentMimeTypeResolver(
    private val contentResolver: ContentResolver,
    private val mimeTypeFromExtension: (String) -> String? = {
        MimeTypeMap.getSingleton().getMimeTypeFromExtension(it)
    },
) {
    /**
     * The [requested] MIME type if any, or else the one [fileName]'s extension
     * stands for, or else [sourceUri]'s if the file is copied from one, or else
     * `application/octet-stream`.
     *
     * The extension comes before the source: a provider may add an extension
     * that matches the MIME type, so the two should agree.
     */
    fun resolve(requested: String?, fileName: String, sourceUri: Uri?): String {
        if (requested != null) {
            return requested
        }

        val extension = fileName.substringAfterLast('.', missingDelimiterValue = "")
        if (extension.isNotEmpty()) {
            mimeTypeFromExtension(extension.lowercase())?.let { return it }
        }

        return sourceUri?.let { contentResolver.getType(it) } ?: OCTET_STREAM
    }

    private companion object {
        private const val OCTET_STREAM = "application/octet-stream"
    }
}
