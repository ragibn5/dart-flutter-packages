package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.os.Build
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaItemData
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

internal class MediaStoreServiceImpl(
    private val contentResolver: ContentResolver,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO,
) : MediaStoreService {
    override suspend fun getPhotos(): List<MediaItemData> = withContext(dispatcher) {
        val photos = mutableListOf<MediaItemData>()
        // Querying a column the device's MediaStore doesn't have throws, so
        // API-gated columns are only requested where they exist.
        val hasApi29Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        val hasApi30Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

        val projection = buildList {
            add(MediaStore.Images.Media._ID)
            add(MediaStore.Images.Media.DISPLAY_NAME)
            add(MediaStore.Images.Media.MIME_TYPE)
            add(MediaStore.Images.Media.SIZE)
            add(MediaStore.Images.Media.DATE_ADDED)
            add(MediaStore.Images.Media.DATE_MODIFIED)
            add(MediaStore.Images.Media.DATE_TAKEN)
            add(MediaStore.Images.Media.WIDTH)
            add(MediaStore.Images.Media.HEIGHT)
            if (hasApi29Columns) {
                add(MediaStore.Images.Media.RELATIVE_PATH)
                add(MediaStore.Images.Media.IS_PENDING)
            }
            if (hasApi30Columns) {
                add(MediaStore.Images.Media.IS_TRASHED)
                add(MediaStore.Images.Media.IS_FAVORITE)
            }
        }.toTypedArray()

        contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            null,
            null,
            null,
        )?.use { cursor ->

            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.MIME_TYPE)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
            val dateModifiedColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)
            val dateTakenColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_TAKEN)
            val widthColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.WIDTH)
            val heightColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.HEIGHT)
            val relativePathColumn = if (hasApi29Columns) {
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.RELATIVE_PATH)
            } else null
            val isPendingColumn = if (hasApi29Columns) {
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.IS_PENDING)
            } else null
            val isTrashedColumn = if (hasApi30Columns) {
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.IS_TRASHED)
            } else null
            val isFavoriteColumn = if (hasApi30Columns) {
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.IS_FAVORITE)
            } else null
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val uri =
                    ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)

                val mediaItemData = MediaItemData(
                    id = id.toString(),
                    name = cursor.getString(nameColumn),
                    mimeType = cursor.getString(mimeTypeColumn),
                    sizeInBytes = cursor.getLong(sizeColumn),
                    dateAddedInMillis = cursor.getLong(dateAddedColumn) * 1000,
                    dateModifiedInMillis = cursor.getLong(dateModifiedColumn) * 1000,
                    dateTakenInMillis = cursor.getLongOrNull(dateTakenColumn),
                    uri = uri.toString(),
                    relativePath = relativePathColumn?.let { cursor.getString(it) },
                    width = cursor.getIntOrNull(widthColumn),
                    height = cursor.getIntOrNull(heightColumn),
                    durationInMillis = null,
                    isPending = isPendingColumn?.let { cursor.getInt(it) != 0 },
                    isTrashed = isTrashedColumn?.let { cursor.getInt(it) != 0 },
                    isFavorite = isFavoriteColumn?.let { cursor.getInt(it) != 0 },
                )

                photos.add(mediaItemData)
            }
        }

        photos
    }

    override suspend fun getVideos(): List<MediaItemData> {
        TODO("Not yet implemented")
    }

    /**
     * Reads the column at [index] as a [Long], or `null` if the value is NULL.
     *
     * [getLong] returns `0` for NULL, which would hide "unknown".
     */
    private fun Cursor.getLongOrNull(index: Int): Long? =
        if (isNull(index)) null
        else getLong(index)

    /**
     * Reads the column at [index] as an [Int], or `null` if the value is NULL.
     *
     * [getInt] returns `0` for NULL, which would hide "unknown".
     */
    private fun Cursor.getIntOrNull(index: Int): Int? =
        if (isNull(index)) null
        else getInt(index)
}
