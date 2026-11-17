package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentContentWriter
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreateService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreateServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreator
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMimeTypeResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.document.services.WritableGrantVerifier
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DocumentCreateServiceFactory {
    fun create(context: Context): DocumentCreateService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        return DocumentCreateServiceImpl(
            grantVerifier = WritableGrantVerifier(PersistedTreeGrants(contentResolver)),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
            creator = DocumentCreator(contentResolver, rowReader),
            mimeTypeResolver = DocumentMimeTypeResolver(contentResolver),
            contentWriter = DocumentContentWriter(contentResolver),
        )
    }
}
