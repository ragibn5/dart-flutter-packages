package com.ragibn5.content.io.content_io_android.features.read.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class ReadRequest(
    /**
     * The id of the [com.ragibn5.content.io.content_io_android.features.read.io.session.ContentReadSession] to read from.
     *
     * Note: Must be a valid session id obtained from `openReadSession`.
     * */
    val sessionId: String,
    /**
     * The offset in bytes to start reading from.
     *
     * Note: Must be >=0 and <= [com.ragibn5.content.io.content_io_android.features.read.io.session.ContentReadSession.sizeInBytes].
     * */
    val start: Long = 0L,
    /**
     * The count of bytes to read.
     *
     * Notes:
     * - This must be >= 0.
     * - The actual length of returned bytes may be less depending on availability.
     * */
    val length: Long,
) {
    init {
        require(start >= 0) { "Invalid start offset - must be >=0" }
        require(length >= 0) { "Invalid length - must be >= 0" }
    }
}