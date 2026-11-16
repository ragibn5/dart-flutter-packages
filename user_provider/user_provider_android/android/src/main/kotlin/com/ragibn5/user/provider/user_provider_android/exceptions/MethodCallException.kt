package com.ragibn5.user.provider.user_provider_android.exceptions

internal class MethodCallException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)