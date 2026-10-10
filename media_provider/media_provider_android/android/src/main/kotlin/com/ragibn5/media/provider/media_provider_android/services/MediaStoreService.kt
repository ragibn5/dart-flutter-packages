package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
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
    suspend fun getMedia(spec: QuerySpec): List<MediaItem>
}

internal object MediaStoreServiceFactory {
    fun create(context: Context): MediaStoreService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val uriBuilder: MediaItemUriBuilder = MediaItemUriBuilder.DEFAULT
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        val fileLocationResolver = FileLocationResolver(storageManager, volumePathResolver)
        return MediaStoreServiceImpl(
            contentResolver = context.contentResolver,
            queryBuilder = MediaQueryBuilder(
                storageManager = storageManager,
                volumePathResolver = volumePathResolver,
            ),
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(
                fileLocationResolver = fileLocationResolver,
                uriBuilder = uriBuilder,
                sdkInt = sdkInt
            ),
            sdkInt = sdkInt,
        )
    }
}

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val queryBuilder: MediaQueryBuilder,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) : MediaStoreService {
    override suspend fun getMedia(spec: QuerySpec): List<MediaItem> {
        if (spec.types.isEmpty() || spec.volumes.isEmpty()) {
            return emptyList()
        }

        val queries = queryBuilder.build(spec)
        if (queries.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            queries.flatMap(::queryMedia)
        }
    }

    private fun queryMedia(query: MediaQuery): List<MediaItem> {
        val media = mutableListOf<MediaItem>()

        contentResolver.query(
            query.uri,
            MediaColumnsReader.projectionFor(sdkInt).toTypedArray(),
            query.selection,
            query.selectionArgs,
            null,
        )?.use { cursor ->
            val reader = mediaColumnsReaderFactory.create(cursor)
            while (cursor.moveToNext()) {
                media += reader.read(query.type, query.uri)
            }
        }

        return media
    }
}