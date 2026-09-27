package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaItemData
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    override suspend fun getPhotos(): List<MediaItemData> = withContext(dispatcher) {
        val collectionUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val photos = mutableListOf<MediaItemData>()

        contentResolver.query(
            collectionUri,
            MediaColumnsReader.projection.toTypedArray(),
            null,
            null,
            null,
        )?.use { cursor ->
            val columns = MediaColumnsReader(cursor)
            while (cursor.moveToNext()) {
                photos.add(columns.read(MediaType.PHOTO, collectionUri))
            }
        }

        return@withContext photos
    }
}
