package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentListService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentListServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentListServiceFactory {
    fun create(context: Context): DocumentListService {
        val rowReader = DocumentRowReader(context.contentResolver)
        return DocumentListServiceImpl(
            grants = PersistedTreeGrants(context.contentResolver),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
        )
    }
}
