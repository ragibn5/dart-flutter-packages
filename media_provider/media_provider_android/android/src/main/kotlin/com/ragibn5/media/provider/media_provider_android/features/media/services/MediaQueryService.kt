package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal fun interface MediaQueryService {
    /**
     * Get the media matching [spec] from the media store.
     *
     * @return An empty list if the request selects nothing, or if none of the
     * requested volumes exist on the device.
     */
    suspend fun queryMedia(spec: QuerySpec): List<MediaItem>
}

internal class MediaQueryServiceImpl(
    private val contentResolver: ContentResolver,
    private val fileLocationResolver: FileLocationResolver,
    private val mediaQueryBuilder: MediaQueryBuilder,
    private val mediaItemUriBuilder: MediaItemUriBuilder = MediaItemUriBuilder,
    private val mediaColumnsReaderFactory: MediaColumnsReaderFactory,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaQueryService {
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
}
