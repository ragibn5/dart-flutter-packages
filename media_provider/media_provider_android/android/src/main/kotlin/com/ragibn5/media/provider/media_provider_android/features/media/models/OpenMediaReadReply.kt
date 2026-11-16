package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonClassDiscriminator

/**
 * The reply to `openMediaReadSession`: how the item can be read.
 *
 * Encoded with a `kind` of `descriptor` or `channel`, which the Dart side
 * decodes into the matching type.
 */
@SuppressLint("UnsafeOptInUsageError")
@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonClassDiscriminator("kind")
internal sealed interface OpenMediaReadReply {
    /**
     * A file descriptor handed over to the Dart side.
     *
     * Notes:
     * - The descriptor is detached: this side keeps no session for it, and
     *   the Dart side owns and closes it.
     * - [offset] is non-zero for a section of a larger file.
     */
    @Serializable
    @SerialName("descriptor")
    data class Descriptor(
        /** The file descriptor. */
        val fd: Int,
        /** The offset of the item's first byte in the descriptor. */
        val offset: Long,
        /** The size of the item in bytes, or `null` if unknown. */
        val sizeInBytes: Long?,
        /** Whether the descriptor can be read at an offset. */
        val isSeekable: Boolean,
    ) : OpenMediaReadReply

    /**
     * A session on this side, read with `readFromSession`.
     *
     * Note: Used only for an item that can't be opened as a descriptor.
     */
    @Serializable
    @SerialName("channel")
    data class Channel(
        /** The id of the session. */
        val sessionId: String,
        /** The size of the item in bytes, or `null` if unknown. */
        val sizeInBytes: Long?,
        /** Whether the session can be read at an offset. */
        val isSeekable: Boolean,
    ) : OpenMediaReadReply
}
