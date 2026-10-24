package com.ragibn5.media.provider.media_provider_android.features.media.io.session

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import java.io.InputStream

/**
 * A [MediaReadSession] for an item that can only be read as a stream, in order.
 *
 * Note: Used only when the item can't be opened as a descriptor, which the
 * Dart side reads by itself.
 */
internal class StreamMediaReadSession(
    override val sessionId: String,
    /** The item's stream; closed with the session. */
    private val stream: InputStream,
) : MediaReadSession {
    /** The number of bytes read so far. */
    private var position = 0L

    override val sizeInBytes: Long? = null

    override val isSeekable: Boolean = false

    @Synchronized
    override fun read(start: Long, length: Long): ByteArray {
        if (start != position) {
            throw MediaProviderException(
                MediaReadExceptionCodes.INVALID_REQUEST,
                "Session $sessionId can only be read in order: expected start $position, got $start"
            )
        }

        val result = ByteArray(minOf(length, Int.MAX_VALUE.toLong()).toInt())
        var totalRead = 0
        while (totalRead < result.size) {
            val bytesRead = stream.read(result, totalRead, result.size - totalRead)
            if (bytesRead == -1) {
                break
            }
            totalRead += bytesRead
        }
        position += totalRead

        return if (totalRead == result.size) result else result.copyOf(totalRead)
    }

    @Suppress("kotlin:S6514")
    @Synchronized
    override fun close() {
        stream.close()
    }
}
