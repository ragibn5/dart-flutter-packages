package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.MediaQueryRequest
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal interface MediaStoreService {
    /**
     * Get the media matching [request] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun getMedia(request: MediaQueryRequest): List<MediaItem>
}

internal object MediaStoreServiceFactory {
    fun create(context: Context): MediaStoreService {
        val sdkInt: Int = Build.VERSION.SDK_INT
        val uriBuilder: MediaUriBuilder = MediaUriBuilder.DEFAULT
        val storageManager = context.getSystemService(StorageManager::class.java)
        val volumeInfoResolver = VolumeInfoResolver(storageManager, sdkInt)
        val volumePathResolver = VolumePathResolver(context, storageManager, sdkInt)
        val fileLocationResolver = FileLocationResolver(storageManager, volumePathResolver)
        return MediaStoreServiceImpl(
            contentResolver = context.contentResolver,
            queryBuilder = MediaStoreQueryBuilder(
                mediaUriFactory = MediaUriFactory(volumeInfoResolver),
            ),
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(
                volumeInfoResolver = volumeInfoResolver,
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
    private val queryBuilder: MediaStoreQueryBuilder,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) : MediaStoreService {
    override suspend fun getMedia(request: MediaQueryRequest): List<MediaItem> {
        if (request.types.isEmpty() || request.volumes.isEmpty()) {
            return emptyList()
        }

        val queries = queryBuilder.build(request)
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