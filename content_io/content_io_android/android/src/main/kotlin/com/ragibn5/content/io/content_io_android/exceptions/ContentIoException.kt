package com.ragibn5.content.io.content_io_android.exceptions

internal object ContentIoCommonExceptionCodes {
    const val ERROR_CODE_UNEXPECTED = "unexpected_error"
}

internal class ContentIoException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)