package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.util.Log
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderCommonExceptionCodes
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.utils.Laps
import com.ragibn5.media.provider.media_provider_android.utils.timed
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedInputStream
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.nio.ByteBuffer

internal interface MediaStoreService {
    /**
     * Get the media matching [spec] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun queryMedia(spec: QuerySpec): List<MediaItem>

    /**
     * Get the media matching [spec] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun openReadSession(request: OpenMediaReadRequest): MediaReadSession

    /**
     * Get the media matching [spec] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun readFromSession(request: MediaReadRequest): ByteArray

    /**
     * Experimental: [readFromSession] on the calling thread, without switching
     * to an IO dispatcher. For callers already off the main thread, such as a
     * background task queue channel.
     */
    fun readFromSessionBlocking(request: MediaReadRequest): ByteArray =
        throw UnsupportedOperationException("Blocking reads are not supported")

    /**
     * Closes the session [sessionId] and releases everything it holds open.
     *
     * Does nothing if no such session is open.
     */
    suspend fun closeReadSession(sessionId: String) {}
}

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val fileLocationResolver: FileLocationResolver,
    private val mediaQueryBuilder: MediaQueryBuilder,
    private val mediaItemUriBuilder: MediaItemUriBuilder = MediaItemUriBuilder,
    private val mediaReadSessionFactory: MediaReadSessionFactory,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    private val sessionRegistry = MediaReadSessionRegistry()

    override suspend fun queryMedia(spec: QuerySpec): List<MediaItem> {
        if (spec.types.isEmpty() || spec.volumes.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            val queries = mediaQueryBuilder.build(spec)
            return@withContext queries.flatMap { query ->
                return@flatMap buildList {
                    contentResolver.query(
                        query.uri,
                        mediaColumnsReaderFactory.projection.toTypedArray(),
                        query.selection,
                        query.selectionArgs,
                        null,
                    )?.use { cursor ->
                        val reader = mediaColumnsReaderFactory.create(cursor)
                        while (cursor.moveToNext()) {
                            val column = reader.read()
                            val fileLocation = column.data?.let(fileLocationResolver::resolve)
                            val contentUri =
                                mediaItemUriBuilder.build(query.uri, column.id.toLong())
                            add(column.toMediaItem(query, contentUri, fileLocation))
                        }
                    }
                }
            }
        }
    }

    override suspend fun openReadSession(request: OpenMediaReadRequest): MediaReadSession {
        // The query and the open both block, so keep them off the main thread.
        return withContext(dispatcher) {
            mediaReadSessionFactory.create(request).getOrThrow()
        }.also { sessionRegistry.addSession(it) }
    }

    override suspend fun readFromSession(request: MediaReadRequest): ByteArray {
        return readFromSessionV4(request)
    }

    override fun readFromSessionBlocking(request: MediaReadRequest): ByteArray {
        return readFromSessionV5(request)
    }

    override suspend fun closeReadSession(sessionId: String) {
        val session = sessionRegistry.removeSession(sessionId) ?: return
        withContext(dispatcher) {
            // Closing the stream also closes the FileInputStream and its channel.
            runCatching { session.stream?.close() }
                .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
            runCatching { session.descriptor?.close() }
                .onFailure { Log.w(TAG, "Failed to close the session descriptor", it) }
        }
    }

    // Opens streams each time called.
    // Uses FileInputStream read - wrapped by BufferedInputStream
    // Skips stream to start position each time called.
    // Takes ~ 600ms
    suspend fun readFromSessionV1(request: MediaReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId] ?: throw MediaProviderException(
            MediaReadExceptionCodes.SESSION_NOT_FOUND,
            "The requested session does not seem to exist, or was removed"
        )

        return withContext(dispatcher) {
            var totalReadCount = 0L
            var bis: BufferedInputStream? = null
            var bos: ByteArrayOutputStream? = null
            try {
                bos = ByteArrayOutputStream()
                bis = contentResolver.openInputStream(session.contentUri.toUri())
                    ?.let { BufferedInputStream(it) }
                    ?: throw MediaProviderException(
                        MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                        "Failed to open the media item for reading"
                    )

                // First skip to the start position
                bis.skip(request.start)

                // Now read
                val bufferSize = 8 * 1024
                val buffer = ByteArray(bufferSize)
                while (totalReadCount < request.length) {
                    val bytesToRead =
                        minOf(buffer.size.toLong(), request.length - totalReadCount).toInt()

                    val bytesRead = bis.read(buffer, 0, bytesToRead)
                    if (bytesRead == -1) {
                        break
                    }

                    bos.write(buffer, 0, bytesRead)
                    totalReadCount += bytesRead
                }
            } catch (e: Exception) {
                throw MediaProviderException(
                    MediaReadExceptionCodes.READ_ERROR,
                    "Error while reading the media item",
                    cause = e.cause
                )
            } finally {
                bos?.close()
                bis?.close()
            }

            return@withContext bos.toByteArray()
        }
    }

    // Opens streams each time called.
    // Uses FileInputStream read + channel positioning first
    // Seeks channel stream to start position each time called.
    // Takes ~581ms
    suspend fun readFromSessionV2(request: MediaReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId] ?: throw MediaProviderException(
            MediaReadExceptionCodes.SESSION_NOT_FOUND,
            "The requested session does not seem to exist, or was removed"
        )

        return withContext(dispatcher) {
            try {
                val pfd = contentResolver.openFileDescriptor(
                    session.contentUri.toUri(),
                    "r"
                ) ?: throw MediaProviderException(
                    MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                    "Failed to open the media item for reading"
                )

                pfd.use {
                    FileInputStream(it.fileDescriptor).use { input ->
                        val channel = input.channel
                        channel.position(request.start)

                        val result = ByteArray(
                            minOf(request.length, Int.MAX_VALUE.toLong()).toInt()
                        )
                        var totalRead = 0

                        while (totalRead < result.size) {
                            val buffer = ByteBuffer.wrap(
                                result,
                                totalRead,
                                result.size - totalRead
                            )

                            val bytesRead = channel.read(buffer)
                            if (bytesRead == -1) break
                            if (bytesRead == 0) continue

                            totalRead += bytesRead
                        }

                        if (totalRead == result.size) result
                        else result.copyOf(totalRead)
                    }
                }
            } catch (e: Exception) {
                throw MediaProviderException(
                    MediaReadExceptionCodes.READ_ERROR,
                    "Error while reading the media item",
                    cause = e
                )
            }
        }
    }

    // Opens streams each time called.
    // Uses Wrapped BufferInputStream read + channel positioning first
    // Seeks channel stream to start position each time called.
    // Takes ~579ms
    suspend fun readFromSessionV3(request: MediaReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw MediaProviderException(
                MediaReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed"
            )

        return withContext(dispatcher) {
            try {
                val pfd = contentResolver.openFileDescriptor(
                    session.contentUri.toUri(),
                    "r"
                ) ?: throw MediaProviderException(
                    MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                    "Failed to open the media item for reading"
                )

                pfd.use {
                    FileInputStream(it.fileDescriptor).use { input ->
                        input.channel.position(request.start)

                        BufferedInputStream(input).use { bufferedInput ->
                            val result = ByteArray(
                                minOf(request.length, Int.MAX_VALUE.toLong()).toInt()
                            )
                            var totalRead = 0

                            while (totalRead < result.size) {
                                val bytesRead = bufferedInput.read(
                                    result,
                                    totalRead,
                                    result.size - totalRead
                                )

                                if (bytesRead == -1) break
                                if (bytesRead == 0) continue

                                totalRead += bytesRead
                            }

                            if (totalRead == result.size) result
                            else result.copyOf(totalRead)
                        }
                    }
                }
            } catch (e: Exception) {
                throw MediaProviderException(
                    MediaReadExceptionCodes.READ_ERROR,
                    "Error while reading the media item",
                    cause = e
                )
            }
        }
    }

    // Reuses the channel opened with the session.
    // Uses FileChannel positional read (pread) - doesn't move the channel position.
    // Takes ~?ms
    suspend fun readFromSessionV4(request: MediaReadRequest): ByteArray {
        val label = "[V4 start=${request.start}]"
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw MediaProviderException(
                MediaReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed"
            )
        val channel = session.channel
            ?: throw MediaProviderException(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The session has no open channel to read from"
            )

        val laps = Laps(label)
        return withContext(dispatcher) {
            laps.lap("hop main -> IO")
            try {
                val result = timed("$label allocate ${request.length}B") {
                    ByteArray(minOf(request.length, Int.MAX_VALUE.toLong()).toInt())
                }
                var totalRead = 0

                timed("$label read loop") {
                    while (totalRead < result.size) {
                        val buffer = ByteBuffer.wrap(
                            result,
                            totalRead,
                            result.size - totalRead
                        )

                        val bytesRead = channel.read(buffer, request.start + totalRead)
                        if (bytesRead == -1) break

                        totalRead += bytesRead
                    }
                }

                timed("$label trim to ${totalRead}B") {
                    if (totalRead == result.size) result
                    else result.copyOf(totalRead)
                }
            } catch (e: Exception) {
                throw MediaProviderException(
                    MediaReadExceptionCodes.READ_ERROR,
                    "Error while reading the media item",
                    cause = e
                )
            }.also { laps.lap("IO work") }
        }.also { laps.lap("hop IO -> main") }
    }

    // Same read as V4, but runs on the calling thread - no dispatcher hops.
    // Meant for the background task queue channel, which already calls in off
    // the main thread.
    // Takes ~?ms
    fun readFromSessionV5(request: MediaReadRequest): ByteArray {
        val label = "[V5 start=${request.start}]"
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw MediaProviderException(
                MediaReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed"
            )
        val channel = session.channel
            ?: throw MediaProviderException(
                MediaProviderCommonExceptionCodes.ERROR_CODE_UNEXPECTED,
                "The session has no open channel to read from"
            )

        return try {
            val result = timed("$label allocate ${request.length}B") {
                ByteArray(minOf(request.length, Int.MAX_VALUE.toLong()).toInt())
            }
            var totalRead = 0

            timed("$label read loop") {
                while (totalRead < result.size) {
                    val buffer = ByteBuffer.wrap(
                        result,
                        totalRead,
                        result.size - totalRead
                    )

                    val bytesRead = channel.read(buffer, request.start + totalRead)
                    if (bytesRead == -1) break

                    totalRead += bytesRead
                }
            }

            timed("$label trim to ${totalRead}B") {
                if (totalRead == result.size) result
                else result.copyOf(totalRead)
            }
        } catch (e: Exception) {
            throw MediaProviderException(
                MediaReadExceptionCodes.READ_ERROR,
                "Error while reading the media item",
                cause = e
            )
        }
    }

    private fun MediaColumn.toMediaItem(
        query: MediaQuery,
        contentUri: String,
        fileLocation: FileLocation?,
    ): MediaItem = MediaItem(
        query.type,
        contentUri,
        fileLocation,
        id = id,
        name = name,
        mimeType = mimeType,
        sizeInBytes = sizeInBytes,
        dateAddedInMillis = dateAddedInMillis,
        dateModifiedInMillis = dateModifiedInMillis,
        dateTakenInMillis = dateTakenInMillis,
        ownerPackageName = ownerPackageName,
        data = data,
        isPending = isPending,
        isTrashed = isTrashed,
        isFavorite = isFavorite,
        isDownloaded = isDownloaded,
    )

    companion object {
        const val TAG = "MediaStoreServiceImpl"
    }
}