package com.ragibn5.document.tree.document_tree_android.features.tree.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeService
import com.ragibn5.document.tree.document_tree_android.features.tree.services.TreeUriDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class GetTreeRequestHandler(
    private val documentTreeService: DocumentTreeService,
    private val treeUriDecoder: TreeUriDecoder = TreeUriDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "getTree"

    override suspend fun handle(call: MethodCall): String? {
        val treeUri = treeUriDecoder.decode(call.arguments<String>()).getOrThrow()
        val tree = documentTreeService.get(treeUri) ?: return null
        return json.encodeToString(tree)
    }
}
