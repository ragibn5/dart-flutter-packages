package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal interface MediaStoreService {
    /**
     * Get all media of [types] managed by the media store.
     *
     * @return An empty list if [types] is empty.
     */
    suspend fun getMedia(types: Set<MediaType>): List<MediaItem>
}

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val collectionRegistry: MediaStoreCollectionRegistry,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    override suspend fun getMedia(types: Set<MediaType>): List<MediaItem> {
        if (types.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            types.flatMap { type ->
                queryMedia(collectionRegistry.get(type))
            }
        }
    }

    private fun queryMedia(collection: MediaStoreCollection): List<MediaItem> {
        val media = mutableListOf<MediaItem>()

        contentResolver.query(
            collection.uri,
            MediaColumnsReader.projection.toTypedArray(),
            null,
            null,
            null,
        )?.use { cursor ->
            val reader = MediaColumnsReader(cursor)
            while (cursor.moveToNext()) {
                media += reader.read(collection)
            }
        }

        return media
    }
}

internal object MediaStoreServiceFactory {
    fun create(contentResolver: ContentResolver): MediaStoreService =
        MediaStoreServiceImpl(
            contentResolver,
            MediaStoreCollectionRegistry(
                setOf(
                    PhotoMediaStoreCollection,
                    VideoMediaStoreCollection,
                )
            )
        )
}