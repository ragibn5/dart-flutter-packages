package com.ragibn5.media.provider.media_provider_android.exceptions

internal class MethodCallException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)