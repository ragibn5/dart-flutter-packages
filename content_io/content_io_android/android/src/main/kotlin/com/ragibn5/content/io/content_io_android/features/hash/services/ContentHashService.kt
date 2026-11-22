package com.ragibn5.content.io.content_io_android.features.hash.services

import com.ragibn5.content.io.content_io_android.exceptions.ContentIoException
import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHash
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.constants.ReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadRequest
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadOpener
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import java.io.IOException
import java.io.InputStream
import java.security.MessageDigest

/**
 * Hashes the content behind URIs, on this side, so its bytes never cross to Dart.
 */
internal fun interface ContentHashService {
    /**
     * Hashes the whole content [request] points to.
     *
     * @return the content's hash, made with [HashContentRequest.algorithm].
     * @throws ContentIoException with an [OpenReadExceptionCodes] code if the
     * content can't be opened, or [ReadExceptionCodes.READ_ERROR] if it can't
     * be read to its end.
     */
    suspend fun hash(request: HashContentRequest): ContentHash
}

internal class ContentHashServiceImpl(
    private val contentReadOpener: ContentReadOpener,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : ContentHashService {
    override suspend fun hash(request: HashContentRequest): ContentHash = withContext(dispatcher) {
        val digest = MessageDigest.getInstance(request.algorithm.digestName)
        contentReadOpener.openStream(OpenReadRequest(request.uri)).getOrThrow().use { input ->
            readInto(digest, input)
        }
        return@withContext ContentHash(request.algorithm, digest.digest().toHex())
    }

    /**
     * Feeds every byte of [input] into [digest], checking for cancellation between chunks.
     */
    private suspend fun readInto(digest: MessageDigest, input: InputStream) {
        val buffer = ByteArray(BUFFER_SIZE_IN_BYTES)
        while (true) {
            currentCoroutineContext().ensureActive()
            val count = try {
                input.read(buffer)
            } catch (e: IOException) {
                throw ContentIoException(
                    ReadExceptionCodes.READ_ERROR,
                    "Error while reading the content",
                    cause = e
                )
            }
            if (count < 0) {
                return
            }
            digest.update(buffer, 0, count)
        }
    }

    private fun ByteArray.toHex(): String = joinToString(separator = "") { "%02x".format(it) }

    private companion object {
        private const val BUFFER_SIZE_IN_BYTES = 256 * 1024
    }
}
