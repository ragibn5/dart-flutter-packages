package com.ragibn5.document.tree.document_tree_android.features.document.constants

/**
 * The failures every document operation shares, thrown by the readers and
 * resolvers they all use.
 */
internal object DocumentAccessExceptionCodes {
    const val ACCESS_LOST = "access_lost"
    const val TREE_UNAVAILABLE = "tree_unavailable"
}

internal object DocumentQueryExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val ACCESS_LOST = DocumentAccessExceptionCodes.ACCESS_LOST
    const val TREE_UNAVAILABLE = DocumentAccessExceptionCodes.TREE_UNAVAILABLE
    const val NOT_FOUND = "not_found"
}

internal object DocumentWriteExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val ACCESS_LOST = DocumentAccessExceptionCodes.ACCESS_LOST
    const val TREE_UNAVAILABLE = DocumentAccessExceptionCodes.TREE_UNAVAILABLE
    const val NOT_WRITABLE = "not_writable"
    const val ALREADY_EXISTS = "already_exists"
    const val SOURCE_NOT_FOUND = "source_not_found"
    const val SOURCE_PERMISSION_DENIED = "source_permission_denied"
    const val NOT_ENOUGH_SPACE = "not_enough_space"
    const val WRITE_ERROR = "write_error"
}
