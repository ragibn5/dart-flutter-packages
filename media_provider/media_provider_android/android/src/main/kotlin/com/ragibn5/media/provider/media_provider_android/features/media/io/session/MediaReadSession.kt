package com.ragibn5.media.provider.media_provider_android.features.media.io.session

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import java.io.Closeable
import java.io.IOException

/**
 * A read session on this side, read by the Dart side with `readFromSession`.
 *
 * Note: Each implementation declares what it supports with [isSeekable], and
 * rejects a read it can't serve.
 */
internal interface MediaReadSession : Closeable {
    /** The id of the session. */
    val sessionId: String

    /** The size of the item in bytes, or `null` if unknown. */
    val sizeInBytes: Long?

    /** Whether [read] accepts any `start`, rather than only where the previous read ended. */
    val isSeekable: Boolean

    /**
     * Reads up to [length] bytes at [start].
     *
     * @param start the offset to read from; when not [isSeekable], it must be
     * where the previous read ended.
     * @param length the maximum number of bytes to read.
     * @return the bytes read; fewer than [length] only at the end of the item.
     * @throws MediaProviderException with [MediaReadExceptionCodes.INVALID_REQUEST]
     * if the session can't read at [start].
     * @throws IOException if reading fails.
     */
    fun read(start: Long, length: Long): ByteArray
}
