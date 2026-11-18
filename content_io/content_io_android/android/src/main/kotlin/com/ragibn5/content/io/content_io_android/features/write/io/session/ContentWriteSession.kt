package com.ragibn5.content.io.content_io_android.features.write.io.session

import java.io.Closeable
import java.io.IOException

/**
 * A write session on this side, written by the Dart side with `writeToSession`.
 */
internal interface ContentWriteSession : Closeable {
    /** The id of the session. */
    val sessionId: String

    /**
     * Writes all of [bytes] after what was written before.
     *
     * @throws IOException if writing fails.
     */
    fun write(bytes: ByteArray)

    /**
     * Waits until everything written is stored.
     *
     * Note: The storage may accept writes into memory and only fail when they
     * reach it, such as when the volume fills up; that failure is reported
     * here.
     *
     * @throws IOException if the content can't be stored.
     */
    fun sync()
}
