package com.ragibn5.document.tree.document_tree_android.features.document.di

import android.content.Context
import com.ragibn5.document.tree.document_tree_android.features.document.services.DirectoryCreateService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DirectoryCreateServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreator
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentPathResolver
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRowReader
import com.ragibn5.document.tree.document_tree_android.features.document.services.WritableGrantVerifier
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants

internal object DirectoryCreateServiceFactory {
    fun create(context: Context): DirectoryCreateService {
        val contentResolver = context.contentResolver
        val rowReader = DocumentRowReader(contentResolver)
        val creator = DocumentCreator(contentResolver, rowReader)
        return DirectoryCreateServiceImpl(
            grantVerifier = WritableGrantVerifier(PersistedTreeGrants(contentResolver)),
            rowReader = rowReader,
            pathResolver = DocumentPathResolver(rowReader),
            creator = creator,
        )
    }
}
