package com.ragibn5.content.io.content_io_android.features.write.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to open existing content for writing.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenWriteRequest(
    /** The `content://` URI of the content to write. */
    val uri: String,
    /** How to treat the content already there. */
    val mode: WriteMode,
)
