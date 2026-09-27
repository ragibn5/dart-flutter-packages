package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.provider.MediaStore
import android.provider.MediaStore.Files.FileColumns
import com.ragibn5.media.provider.media_provider_android.models.MediaItemData
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    override suspend fun getMedia(types: Set<MediaType>): List<MediaItemData> {
        // "IN ()" is invalid SQL.
        if (types.isEmpty()) {
            return emptyList()
        }

        return withContext(dispatcher) {
            val media = mutableListOf<MediaItemData>()

            // All types share the Files table, so one query returns them
            // together instead of merging a query per collection.
            contentResolver.query(
                MediaStore.Files.getContentUri(EXTERNAL_VOLUME),
                MediaColumnsReader.projection.toTypedArray(),
                "${FileColumns.MEDIA_TYPE} IN (${types.joinToString { "?" }})",
                types.map { it.mediaStoreType.toString() }.toTypedArray(),
                null,
            )?.use { cursor ->
                val reader = MediaColumnsReader(cursor)
                while (cursor.moveToNext()) {
                    reader.read()?.let(media::add)
                }
            }

            return@withContext media
        }
    }

    private companion object {
        // MediaStore.VOLUME_EXTERNAL is API 29+.
        private const val EXTERNAL_VOLUME = "external"
    }
}
