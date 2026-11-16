package com.ragibn5.document.tree.document_tree_android.exceptions

internal object DocumentTreeCommonExceptionCodes {
    const val ERROR_CODE_UNEXPECTED = "unexpected_error"
}

internal class DocumentTreeException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)
