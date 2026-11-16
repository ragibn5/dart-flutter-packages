package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.net.toUri
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.tree.constants.TreeRequestExceptionCodes

internal class TreeUriDecoder {
    fun decode(encodedUri: String?): Result<Uri> = runCatching {
        if (encodedUri.isNullOrBlank()) {
            throw invalidArgument("You must provide the tree's uri")
        }

        val uri = encodedUri.toUri()
        if (!DocumentsContract.isTreeUri(uri)) {
            throw invalidArgument("Not a document tree uri: $encodedUri")
        }

        return@runCatching uri
    }

    private fun invalidArgument(message: String) =
        DocumentTreeException(TreeRequestExceptionCodes.INVALID_REQUEST, message)
}
