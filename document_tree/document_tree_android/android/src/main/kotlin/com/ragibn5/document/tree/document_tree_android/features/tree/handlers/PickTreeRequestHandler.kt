package com.ragibn5.document.tree.document_tree_android.features.tree.handlers

import com.ragibn5.document.tree.document_tree_android.MethodCallRequestHandler
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.tree.constants.TreePickExceptionCodes
import com.ragibn5.document.tree.document_tree_android.features.tree.models.PickTreeRequest
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeService
import com.ragibn5.document.tree.document_tree_android.features.tree.services.PickTreeRequestDecoder
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

internal class PickTreeRequestHandler(
    private val documentTreeService: DocumentTreeService,
    private val pickTreeRequestDecoder: PickTreeRequestDecoder = PickTreeRequestDecoder(),
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "pickTree"

    override suspend fun handle(call: MethodCall): String? {
        val tree = documentTreeService.pick(parseRequest(call)) ?: return null
        return json.encodeToString(tree)
    }

    private fun parseRequest(call: MethodCall): PickTreeRequest {
        val argument = call.arguments<String>()
            ?: throw DocumentTreeException(
                code = TreePickExceptionCodes.INVALID_REQUEST,
                message = "You must provide a valid JSON representation of ${PickTreeRequest::class.java.simpleName}"
            )
        return pickTreeRequestDecoder.decode(argument).getOrThrow()
    }
}
