package com.ragibn5.content.io.content_io_android.features.write.models

import android.annotation.SuppressLint
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * How a write session treats the content already there.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal enum class WriteMode(
    /** The mode to open the content with, as `ContentResolver` takes it. */
    val fileMode: String,
) {
    /** Replaces the content: it's emptied when the session opens. */
    @SerialName("truncate")
    TRUNCATE("wt"),

    /** Keeps the content, and writes after its end. */
    @SerialName("append")
    APPEND("wa"),
}
