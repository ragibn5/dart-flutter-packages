package com.ragibn5.content.io.content_io_android.features.write.models

import android.annotation.SuppressLint
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonClassDiscriminator

/**
 * The reply to `openWriteSession`: how the content can be written.
 *
 * Encoded with a `kind` of `descriptor` or `channel`, which the Dart side
 * decodes into the matching type.
 */
@SuppressLint("UnsafeOptInUsageError")
@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonClassDiscriminator("kind")
internal sealed interface OpenWriteReply {
    /**
     * A file descriptor handed over to the Dart side.
     *
     * Note: The descriptor is detached: this side keeps no session for it, and
     * the Dart side owns, syncs and closes it.
     */
    @Serializable
    @SerialName("descriptor")
    data class Descriptor(
        /** The file descriptor. */
        val fd: Int,
    ) : OpenWriteReply

    /**
     * A session on this side, written with `writeToSession`.
     *
     * Note: Used only for content that can't be opened as a descriptor.
     */
    @Serializable
    @SerialName("channel")
    data class Channel(
        /** The id of the session. */
        val sessionId: String,
    ) : OpenWriteReply
}
