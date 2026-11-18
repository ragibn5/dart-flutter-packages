package com.ragibn5.content.io.content_io_android.features.write.constants

/**
 * The codes of a failure to open content for writing.
 *
 * Note: The same codes as [com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes],
 * so the Dart side maps both with one mapper.
 */
internal object OpenWriteExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val CONTENT_NOT_FOUND = "not_found"
    const val PERMISSION_DENIED = "permission_denied"
    const val UNSUPPORTED_OPERATION = "unsupported_operation"
}

internal object WriteExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val SESSION_NOT_FOUND = "session_not_found"
    const val NOT_ENOUGH_SPACE = "not_enough_space"
    const val WRITE_ERROR = "write_error"
}
