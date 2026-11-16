package com.ragibn5.document.tree.document_tree_android.features.tree.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeService
import com.ragibn5.document.tree.document_tree_android.features.tree.services.TreeUriDecoder
import io.flutter.plugin.common.MethodCall

internal class ReleaseTreeRequestHandler(
    private val documentTreeService: DocumentTreeService,
    private val treeUriDecoder: TreeUriDecoder = TreeUriDecoder(),
) : MethodCallRequestHandler {
    override val method = "releaseTree"

    override suspend fun handle(call: MethodCall): Any? {
        documentTreeService.release(treeUriDecoder.decode(call.arguments<String>()).getOrThrow())
        return null
    }
}
