package com.ragibn5.content.io.content_io_android.features.read.services

import android.system.ErrnoException
import android.system.Os
import java.io.FileDescriptor
import java.io.IOException
import java.io.InputStream

/**
 * Reads [length] bytes of [fd] from [start], by position, so the descriptor's own position
 * never moves and it can still be handed over as it is.
 */
internal class PositionalInputStream(
    private val fd: FileDescriptor,
    private val start: Long,
    private val length: Long,
) : InputStream() {
    private var position = 0L

    override fun read(): Int {
        val single = ByteArray(1)
        return if (read(single, 0, 1) == -1) -1 else single[0].toInt() and 0xFF
    }

    override fun read(buffer: ByteArray, offset: Int, count: Int): Int {
        if (count == 0) {
            return 0
        }
        val remaining = length - position
        if (remaining <= 0) {
            return -1
        }
        val read = try {
            Os.pread(fd, buffer, offset, minOf(count.toLong(), remaining).toInt(), start + position)
        } catch (e: ErrnoException) {
            throw IOException("Failed to read the content", e)
        }
        if (read <= 0) {
            return -1
        }
        position += read
        return read
    }

    override fun skip(count: Long): Long {
        val skipped = count.coerceIn(0, (length - position).coerceAtLeast(0))
        position += skipped
        return skipped
    }

    override fun available(): Int = (length - position).coerceIn(0, Int.MAX_VALUE.toLong()).toInt()
}
