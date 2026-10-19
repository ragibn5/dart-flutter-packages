package com.ragibn5.media.provider.media_provider_android.exceptions

internal class MediaProviderException(
    val code: String,
    message: String,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)