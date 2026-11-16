package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentGetService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentGetServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentGetServiceFactory {
    fun create(context: Context): DocumentGetService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        return DocumentGetServiceImpl(
            grants = PersistedTreeGrants(contentResolver),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
        )
    }
}
