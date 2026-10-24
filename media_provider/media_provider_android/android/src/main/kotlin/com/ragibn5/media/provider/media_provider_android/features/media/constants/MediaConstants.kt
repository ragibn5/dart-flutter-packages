package com.ragibn5.media.provider.media_provider_android.features.media.constants

internal object MediaQueryExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
}

internal object OpenMediaReadExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val MEDIA_NOT_FOUND = "not_found"
    const val PERMISSION_DENIED = "permission_denied"
    const val UNSUPPORTED_OPERATION = "unsupported_operation"
}

internal object MediaReadExceptionCodes {
    const val INVALID_REQUEST = "invalid_request"
    const val SESSION_NOT_FOUND = "session_not_found"
    const val READ_ERROR = "read_error"
}