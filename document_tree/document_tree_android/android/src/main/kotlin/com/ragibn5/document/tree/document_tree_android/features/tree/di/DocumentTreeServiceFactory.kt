package com.ragibn5.document.tree.document_tree_android.features.tree.di

import android.content.Context
import android.os.storage.StorageManager
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeResolver
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeService
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeServiceImpl
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PersistedTreeGrants
import com.ragibn5.document.tree.document_tree_android.features.tree.services.TreeLocationResolver
import com.ragibn5.document.tree.document_tree_android.features.tree.services.TreePickerLauncher
import com.ragibn5.document.tree.document_tree_android.features.tree.services.VolumeRootResolver

internal object DocumentTreeServiceFactory {
    fun create(context: Context, pickerLauncher: TreePickerLauncher): DocumentTreeService {
        val grants = PersistedTreeGrants(context.contentResolver)
        val storageManager = context.getSystemService(StorageManager::class.java)
        val locationResolver = TreeLocationResolver(
            context = context,
            storageManager = storageManager,
            volumeRoots = VolumeRootResolver(context, storageManager),
        )
        return DocumentTreeServiceImpl(
            pickerLauncher = pickerLauncher,
            grants = grants,
            treeResolver = DocumentTreeResolver(context.contentResolver, grants, locationResolver),
        )
    }
}
