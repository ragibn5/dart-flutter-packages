package com.ragibn5.document.tree.document_tree_android

import io.flutter.plugin.common.MethodCall

internal interface MethodCallRequestHandler {
    /**
     * Name of the channel method this handler serves.
     */
    val method: String

    /**
     * Handles [call] and returns the value to reply with.
     *
     * Called on the main thread; blocking work must be moved off it.
     * Throws [com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException]
     * to reply with a specific error.
     */
    suspend fun handle(call: MethodCall): Any?
}