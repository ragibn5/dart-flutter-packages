package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.util.Log
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.UUID

internal interface MediaStoreService {
    /**
     * Get the media matching [spec] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun queryMedia(spec: QuerySpec): List<MediaItem>

    /**
     * Opens the item [request] points to for reading.
     *
     * @return a [OpenMediaReadReply.Descriptor] when the item opens as a
     * descriptor, which is handed over and not kept here; otherwise a
     * [OpenMediaReadReply.Channel] for a session kept here, to read with
     * [readFromSession] and close with [closeReadSession].
     * @throws MediaProviderException with an open error code.
     */
    suspend fun openRead(request: OpenMediaReadRequest): OpenMediaReadReply

    /**
     * Reads from the session [MediaReadRequest.sessionId], on the calling
     * thread.
     *
     * @return the bytes read; fewer than requested only at the end of the item.
     * @throws MediaProviderException with a [MediaReadExceptionCodes] code.
     */
    fun readFromSession(request: MediaReadRequest): ByteArray

    /**
     * Closes the session [sessionId] and releases everything it holds open.
     *
     * Does nothing if no such session is open.
     */
    suspend fun closeReadSession(sessionId: String)

    /**
     * Closes every open session, on the calling thread.
     *
     * Note: For when the plugin detaches, as the Dart side can no longer close
     * them.
     */
    fun closeAllReadSessions()
}

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val fileLocationResolver: FileLocationResolver,
    private val mediaQueryBuilder: MediaQueryBuilder,
    private val mediaItemUriBuilder: MediaItemUriBuilder = MediaItemUriBuilder,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val mediaSourceOpener: MediaSourceOpener,
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

    override suspend fun openRead(request: OpenMediaReadRequest): OpenMediaReadReply {
        // Opening blocks, so keep it off the main thread.
        val source = withContext(dispatcher) {
            mediaSourceOpener.open(request).getOrThrow()
        }

        return when (source) {
            is OpenedMediaSource.Descriptor -> OpenMediaReadReply.Descriptor(
                fd = source.fd,
                offset = source.offset,
                sizeInBytes = source.sizeInBytes,
                isSeekable = source.isSeekable,
            )

            is OpenedMediaSource.Stream -> {
                val session = MediaReadSession(UUID.randomUUID().toString(), source.stream)
                sessionRegistry.addSession(session)
                OpenMediaReadReply.Channel(
                    sessionId = session.sessionId,
                    sizeInBytes = null,
                    isSeekable = false,
                )
            }
        }
    }

    override fun readFromSession(request: MediaReadRequest): ByteArray {
        val session = sessionRegistry.sessionMap[request.sessionId]
            ?: throw MediaProviderException(
                MediaReadExceptionCodes.SESSION_NOT_FOUND,
                "The requested session does not seem to exist, or was removed",
                details = mapOf("sessionId" to request.sessionId)
            )

        try {
            return session.read(request.start, request.length)
        } catch (e: IOException) {
            throw MediaProviderException(
                MediaReadExceptionCodes.READ_ERROR,
                "Error while reading the media item",
                cause = e
            )
        }
    }

    override suspend fun closeReadSession(sessionId: String) {
        val session = sessionRegistry.removeSession(sessionId) ?: return
        withContext(dispatcher) {
            runCatching { session.close() }
                .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
        }
    }

    override fun closeAllReadSessions() {
        sessionRegistry.removeAllSessions().forEach { session ->
            runCatching { session.close() }
                .onFailure { Log.w(TAG, "Failed to close the session stream", it) }
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