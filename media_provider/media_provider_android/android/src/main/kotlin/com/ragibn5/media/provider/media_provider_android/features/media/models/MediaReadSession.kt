package com.ragibn5.media.provider.media_provider_android.features.media.models

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import java.io.Closeable
import java.io.IOException
import java.io.InputStream

/**
 * A read session for an item that can only be read as a stream, in order.
 *
 * Note: Used only when the item can't be opened as a descriptor, which the
 * Dart side reads by itself.
 */
internal class MediaReadSession(
    /** The id of the session. */
    val sessionId: String,
    /** The item's stream; closed with the session. */
    private val stream: InputStream,
) : Closeable {
    /** The number of bytes read so far. */
    private var position = 0L

    /**
     * Reads up to [length] bytes, continuing where the previous read ended.
     *
     * @param start the offset to read from; must be where the previous read
     * ended.
     * @param length the maximum number of bytes to read.
     * @return the bytes read; fewer than [length] only at the end of the item.
     * @throws MediaProviderException with [MediaReadExceptionCodes.INVALID_REQUEST]
     * if [start] isn't where the previous read ended.
     * @throws IOException if the stream fails.
     */
    @Synchronized
    fun read(start: Long, length: Long): ByteArray {
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

    @Synchronized
    override fun close() {
        stream.close()
    }
}
