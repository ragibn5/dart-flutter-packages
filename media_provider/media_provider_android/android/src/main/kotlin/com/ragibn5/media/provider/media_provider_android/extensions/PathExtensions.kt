package com.ragibn5.media.provider.media_provider_android.extensions

import java.io.File

internal fun String.ensureTrailingSlash(): String =
    if (this.endsWith(File.separator)) this
    else "$this${File.separator}"

internal fun String.ensureNoTrailingSlash(): String =
    if (this.endsWith(File.separator)) this.substring(0, length - 1)
    else this