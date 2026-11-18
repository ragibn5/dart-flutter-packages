package com.ragibn5.content.io.content_io_android.features.write.io.session

import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream

/**
 * A [ContentWriteSession] for content that can only be written as a stream.
 *
 * Note: Used only when the content can't be opened as a descriptor, which the
 * Dart side writes by itself.
 */
internal class StreamContentWriteSession(
    override val sessionId: String,
    /** The content's stream; closed with the session. */
    private val stream: OutputStream,
) : ContentWriteSession {
    @Synchronized
    override fun write(bytes: ByteArray) {
        stream.write(bytes)
    }

    @Synchronized
    override fun sync() {
        stream.flush()
        val descriptor = (stream as? FileOutputStream)?.fd ?: return
        try {
            // Os.fsync keeps the system's error code, such as ENOSPC; FileDescriptor.sync drops it.
            Os.fsync(descriptor)
        } catch (e: ErrnoException) {
            // A pipe or socket can't be synced: what was flushed is all there is to do.
            if (e.errno != OsConstants.EINVAL && e.errno != OsConstants.EROFS) {
                throw IOException(e.message, e)
            }
        }
    }

    @Suppress("kotlin:S6514")
    @Synchronized
    override fun close() {
        stream.close()
    }
}
