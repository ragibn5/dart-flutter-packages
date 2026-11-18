package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMoveService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMoveServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.document.services.WritableGrantVerifier
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentMoveServiceFactory {
    fun create(context: Context): DocumentMoveService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        return DocumentMoveServiceImpl(
            contentResolver = contentResolver,
            grantVerifier = WritableGrantVerifier(PersistedTreeGrants(contentResolver)),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
        )
    }
}
