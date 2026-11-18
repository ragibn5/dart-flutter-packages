package com.ragibn5.content.io.content_io_android.features.read.io.session

import android.content.res.AssetFileDescriptor
import androidx.annotation.VisibleForTesting
import java.io.InputStream

/**
 * A [ContentReadSession] for a descriptor its provider watches, read in order.
 *
 * Note: Kept on this side rather than handed over to the Dart side, because
 * handing it over detaches it: the provider would then hear that the read
 * failed. Closing it here tells the provider whether the read finished or was
 * cancelled.
 */
internal class WatchedContentReadSession(
    override val sessionId: String,
    /** The content's descriptor; closed with the session. */
    private val descriptor: AssetFileDescriptor,
    @VisibleForTesting
    stream: InputStream = descriptor.createInputStream(),
) : ContentReadSession {
    /** Reads [stream] in order. */
    private val reader = StreamContentReadSession(sessionId, stream)

    /** The number of bytes read so far. */
    private var position = 0L

    /** Whether the end of the content was reached. */
    private var isAtEnd = false

    override val sizeInBytes: Long? =
        descriptor.length.takeIf { it != AssetFileDescriptor.UNKNOWN_LENGTH }

    override val isSeekable: Boolean = false

    @Synchronized
    override fun read(start: Long, length: Long): ByteArray {
        val bytes = reader.read(start, length)
        position += bytes.size
        // A read returns fewer bytes than asked for only at the end.
        if (bytes.size < length || position == sizeInBytes) {
            isAtEnd = true
        }
        return bytes
    }

    /**
     * Ends the session: tells the provider the read finished if it reached
     * the end, otherwise that it was cancelled.
     */
    @Synchronized
    override fun close() {
        if (isAtEnd) {
            reader.close()
        } else {
            descriptor.parcelFileDescriptor.closeWithError(CANCELLED)
        }
    }

    private companion object {
        /** What the provider is told when the read ends early. */
        const val CANCELLED = "The read was cancelled"
    }
}
