package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.util.Log
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

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
    suspend fun openReadSession(request: MediaReadRequest): MediaReadSession
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
    override suspend fun queryMedia(spec: QuerySpec): List<MediaItem> {
        if (spec.types.isEmpty() || spec.volumes.isEmpty()) {
            return emptyList()
        }

        val queries = mediaQueryBuilder.build(spec)
        if (queries.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            queries.flatMap { query ->
                val mediaList = mutableListOf<MediaItem>()

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
                        val fileLocation =
                            column.data?.let { fileLocationResolver.resolve(it) }
                        val contentUri = runCatching {
                            mediaItemUriBuilder.build(query.uri, column.id.toLong())
                        }.getOrElse {
                            Log.e(TAG, "Failed to build content uri", it)
                            continue
                        }
                        mediaList += column.toMediaItem(query, contentUri, fileLocation)
                    }
                }

                return@flatMap mediaList
            }
        }
    }

    override suspend fun openReadSession(request: MediaReadRequest): MediaReadSession {
        return mediaReadSessionFactory.create(request).getOrThrow()
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