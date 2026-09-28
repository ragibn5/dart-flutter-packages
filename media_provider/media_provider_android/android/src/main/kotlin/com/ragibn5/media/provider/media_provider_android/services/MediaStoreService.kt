package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.os.Build
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
    private val uriBuilder: MediaUriBuilder = MediaUriBuilder.DEFAULT,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
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
            MediaColumnsReader.projectionFor(sdkInt).toTypedArray(),
            null,
            null,
            null,
        )?.use { cursor ->
            val reader = MediaColumnsReader(cursor, sdkInt, uriBuilder)
            while (cursor.moveToNext()) {
                media += reader.read(collection)
            }
        }

        return media
    }
}

internal object MediaStoreServiceFactory {
    /**
     * The collections exist on a device, so they are looked up lazily: reading
     * `MediaStore.*.EXTERNAL_CONTENT_URI` eagerly would fail anywhere the
     * framework is not present, such as a JVM unit test.
     */
    private val collections: Set<MediaStoreCollection> by lazy {
        setOf(
            PhotoMediaStoreCollection,
            VideoMediaStoreCollection,
        )
    }

    fun create(contentResolver: ContentResolver): MediaStoreService =
        MediaStoreServiceImpl(
            contentResolver,
            MediaStoreCollectionRegistry(collections),
        )
}