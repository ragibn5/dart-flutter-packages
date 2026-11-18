package com.ragibn5.content.io.content_io_android.features.write.io.session

import android.os.ParcelFileDescriptor
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import androidx.annotation.VisibleForTesting
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStream

/**
 * A [ContentWriteSession] for a descriptor its provider watches, such as a
 * pipe it streams the content through, or a file it uploads once closed.
 *
 * Note: Kept on this side rather than handed over to the Dart side, because
 * handing it over detaches it: the provider would then hear that the write
 * failed, never that it finished. Closing it here tells the provider how the
 * write ended.
 */
internal class WatchedContentWriteSession(
    override val sessionId: String,
    /** The content's descriptor; closed with the session. */
    private val descriptor: ParcelFileDescriptor,
    @VisibleForTesting
    private val stream: OutputStream = FileOutputStream(descriptor.fileDescriptor),
) : ContentWriteSession {
    @Synchronized
    override fun write(bytes: ByteArray) {
        stream.write(bytes)
    }

    @Synchronized
    override fun sync() {
        stream.flush()
        try {
            // Os.fsync keeps the system's error code, such as ENOSPC; FileDescriptor.sync drops it.
            Os.fsync(descriptor.fileDescriptor)
        } catch (e: ErrnoException) {
            // A pipe or socket can't be synced: what was flushed is all there is to do.
            if (e.errno != OsConstants.EINVAL && e.errno != OsConstants.EROFS) {
                throw IOException(e.message, e)
            }
        }
    }

    @Synchronized
    override fun close() {
        descriptor.close()
    }

    @Synchronized
    override fun abort(reason: String) {
        descriptor.closeWithError(reason)
    }
}
