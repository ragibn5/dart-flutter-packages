package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaReadSession
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
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
    suspend fun openMediaForReading(request: MediaReadRequest): MediaReadSession
}

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val queryBuilder: MediaQueryBuilder,
    private val mediaReadSessionFactory: MediaReadSessionFactory,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    override suspend fun queryMedia(spec: QuerySpec): List<MediaItem> {
        if (spec.types.isEmpty() || spec.volumes.isEmpty()) {
            return emptyList()
        }

        val queries = queryBuilder.build(spec)
        if (queries.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            queries.flatMap {
                val mediaList = mutableListOf<MediaItem>()

                contentResolver.query(
                    it.uri,
                    mediaColumnsReaderFactory.projection.toTypedArray(),
                    it.selection,
                    it.selectionArgs,
                    null,
                )?.use { cursor ->
                    val reader = mediaColumnsReaderFactory.create(cursor)
                    while (cursor.moveToNext()) {
                        mediaList += reader.read(it.type, it.uri)
                    }
                }

                return@flatMap mediaList
            }
        }
    }

    override suspend fun openMediaForReading(request: MediaReadRequest): MediaReadSession {
        return mediaReadSessionFactory.create(request).getOrThrow()
    }
}