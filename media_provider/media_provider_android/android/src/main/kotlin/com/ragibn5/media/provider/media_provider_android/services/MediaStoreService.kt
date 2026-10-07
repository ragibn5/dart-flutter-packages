package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollection
import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollectionRegistry
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.PhotoMediaStoreCollection
import com.ragibn5.media.provider.media_provider_android.models.VideoMediaStoreCollection
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
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
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
            val reader = mediaColumnsReaderFactory.create(cursor)
            while (cursor.moveToNext()) {
                media += reader.read(collection)
            }
        }

        return media
    }
}

internal object MediaStoreServiceFactory {
    fun create(
        context: Context,
        collections: Set<MediaStoreCollection> = setOf(
            PhotoMediaStoreCollection,
            VideoMediaStoreCollection,
        ),
    ): MediaStoreService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val uriBuilder: MediaUriBuilder = MediaUriBuilder.DEFAULT
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumeInfoResolver = VolumeInfoResolver(storageManager, sdkInt)
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        val fileLocationResolver = FileLocationResolver(storageManager, volumePathResolver)
        return MediaStoreServiceImpl(
            contentResolver = context.contentResolver,
            collectionRegistry = MediaStoreCollectionRegistry(collections),
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(
                volumeInfoResolver = volumeInfoResolver,
                fileLocationResolver = fileLocationResolver,
                uriBuilder = uriBuilder,
                sdkInt = sdkInt
            ),
        )
    }
}
