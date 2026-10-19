package com.ragibn5.media.provider.media_provider_android.exceptions

internal object MediaProviderCommonErrorCodes {
    const val ERROR_CODE_UNEXPECTED = "unexpected_error"
}

internal class MediaProviderException(
    val code: String,
    message: String? = null,
    val details: Any? = null,
    cause: Throwable? = null,
) : Exception(message, cause)