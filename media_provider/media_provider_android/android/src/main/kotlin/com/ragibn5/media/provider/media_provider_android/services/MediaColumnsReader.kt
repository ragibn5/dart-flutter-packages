package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentUris
import android.database.Cursor
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import androidx.core.database.getLongOrNull
import androidx.core.database.getStringOrNull
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.services.MediaColumnsReader.Companion.projection

/**
 * Reads [MediaItem] values from a cursor over a MediaStore collection.
 *
 * The cursor must have been queried with (at least) [projection].
 */
internal class MediaColumnsReader(
    private val cursor: Cursor,
) {
    private val idColumn = cursor.getColumnIndexOrThrow(BaseColumns._ID)
    private val nameColumn = cursor.getColumnIndexOrThrow(MediaColumns.DISPLAY_NAME)
    private val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE)
    private val sizeColumn = cursor.getColumnIndexOrThrow(MediaColumns.SIZE)
    private val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_ADDED)
    private val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_MODIFIED)
    private val relativePathColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.RELATIVE_PATH)
    } else {
        null
    }
    private val isPendingColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_PENDING)
    } else {
        null
    }
    private val isTrashedColumn = if (hasApi30Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_TRASHED)
    } else {
        null
    }
    private val isFavoriteColumn = if (hasApi30Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_FAVORITE)
    } else {
        null
    }

    /**
     * Reads the current cursor row.
     */
    fun read(collection: MediaStoreCollection): MediaItem {
        val id = cursor.getLong(idColumn)
        return MediaItem(
            type = collection.type,
            id = id.toString(),
            uri = ContentUris.withAppendedId(
                collection.uri,
                id,
            ).toString(),
            name = cursor.getStringOrNull(nameColumn),
            mimeType = cursor.getStringOrNull(mimeTypeColumn),
            sizeInBytes = cursor.getLongOrNull(sizeColumn),
            dateAddedInMillis = cursor.getLongOrNull(dateAddedColumn)?.times(1000),
            dateModifiedInMillis = cursor.getLongOrNull(dateModifiedColumn)?.times(1000),
            relativePath = relativePathColumn?.let(cursor::getStringOrNull),
            isPending = isPendingColumn?.let(cursor::getBooleanOrNull),
            isTrashed = isTrashedColumn?.let(cursor::getBooleanOrNull),
            isFavorite = isFavoriteColumn?.let(cursor::getBooleanOrNull),
        )
    }

    companion object {
        private val hasApi29Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        private val hasApi30Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

        /**
         * Columns to request for [MediaColumnsReader] on this device.
         */
        val projection: List<String> = buildList {
            add(BaseColumns._ID)
            add(MediaColumns.DISPLAY_NAME)
            add(MediaColumns.MIME_TYPE)
            add(MediaColumns.SIZE)
            add(MediaColumns.DATE_ADDED)
            add(MediaColumns.DATE_MODIFIED)

            if (hasApi29Columns) {
                add(MediaColumns.RELATIVE_PATH)
                add(MediaColumns.IS_PENDING)
            }

            if (hasApi30Columns) {
                add(MediaColumns.IS_TRASHED)
                add(MediaColumns.IS_FAVORITE)
            }
        }
    }
}