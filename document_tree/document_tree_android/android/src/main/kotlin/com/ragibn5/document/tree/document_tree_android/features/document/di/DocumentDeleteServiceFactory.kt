package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentDeleteService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentDeleteServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.document.services.WritableGrantVerifier
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentDeleteServiceFactory {
    fun create(context: Context): DocumentDeleteService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        return DocumentDeleteServiceImpl(
            contentResolver = contentResolver,
            grantVerifier = WritableGrantVerifier(PersistedTreeGrants(contentResolver)),
            pathResolver = DocumentPathResolver(rowReader),
        )
    }
}
