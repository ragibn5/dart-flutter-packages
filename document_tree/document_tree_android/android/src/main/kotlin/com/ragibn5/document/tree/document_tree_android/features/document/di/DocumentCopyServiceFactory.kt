package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCopyService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCopyServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreator
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMimeTypeResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentCopyServiceFactory {
    fun create(context: Context): DocumentCopyService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        val creator = DocumentCreator(contentResolver, rowReader)
        return DocumentCopyServiceImpl(
            contentResolver = contentResolver,
            grants = PersistedTreeGrants(contentResolver),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader, creator),
            creator = creator,
            mimeTypeResolver = DocumentMimeTypeResolver(contentResolver),
        )
    }
}
