package com.ragibn5.content.io.content_io_android.features.read.io.session

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import java.io.InputStream

/**
 * A [ContentReadSession] for content that can only be read as a stream, in order.
 *
 * Note: Used only when the content can't be opened as a descriptor, which the
 * Dart side reads by itself.
 */
internal class StreamContentReadSession(
    override val sessionId: String,
    /** The content's stream; closed with the session. */
    private val stream: InputStream,
) : ContentReadSession {
    /** The number of bytes read so far. */
    private var position = 0L

    override val sizeInBytes: Long? = null

    override val isSeekable: Boolean = false

    @Synchronized
    override fun read(start: Long, length: Long): ByteArray {
        if (start != position) {
            throw ContentIoException(
                ReadExceptionCodes.INVALID_REQUEST,
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
