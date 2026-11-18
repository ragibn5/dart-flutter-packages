package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRenameService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRenameServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.document.services.WritableGrantVerifier
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentRenameServiceFactory {
    fun create(context: Context): DocumentRenameService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        return DocumentRenameServiceImpl(
            contentResolver = contentResolver,
            grantVerifier = WritableGrantVerifier(PersistedTreeGrants(contentResolver)),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
        )
    }
}
