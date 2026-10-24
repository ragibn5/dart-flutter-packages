package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import android.os.ParcelFileDescriptor
import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient
import java.io.InputStream
import java.nio.channels.FileChannel

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal class MediaReadSession(
    val sessionId: String,
    val contentUri: String,
    val sizeInBytes: Long?,
    val isSeekable: Boolean,
) {
    @Transient
    var channel: FileChannel? = null

    @Transient
    var descriptor: ParcelFileDescriptor? = null

    @Transient
    var stream: InputStream? = null

    /**
     * **Experimental**
     *
     * The absolute path of the underlying file descriptor.
     *
     * Dart side can use it to open and read directly, bypassing the channel.
     *
     * Notes:
     * - May be null if the media item is not backed by a physical file.
     * - Valid only in this process, and only while the session is open.
     */
    var descriptorPath: String? = null

    /**
     * **Experimental**
     *
     * The number of the underlying file [descriptor].
     *
     * Dart side can use it to read with `pread` over FFI, without reopening the file.
     *
     * Notes:
     * - May be null if the media item is not backed by a physical file.
     * - Valid only in this process, and only while the session is open.
     */
    var descriptorFd: Int? = null
}