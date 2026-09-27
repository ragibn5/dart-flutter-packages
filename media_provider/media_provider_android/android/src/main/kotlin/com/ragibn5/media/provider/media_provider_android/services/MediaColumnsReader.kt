package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentUris
import android.database.Cursor
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.Files.FileColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.models.MediaItemData
import com.ragibn5.media.provider.media_provider_android.services.MediaColumnsReader.Companion.projection

/**
 * Reads [MediaItemData] from a cursor over `MediaStore.Files`.
 *
 * The cursor must have been queried with (at least) [projection].
 */
internal class MediaColumnsReader(private val cursor: Cursor) {
    private val idColumn = cursor.getColumnIndexOrThrow(BaseColumns._ID)
    private val mediaTypeColumn = cursor.getColumnIndexOrThrow(FileColumns.MEDIA_TYPE)
    private val nameColumn = cursor.getColumnIndexOrThrow(MediaColumns.DISPLAY_NAME)
    private val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE)
    private val sizeColumn = cursor.getColumnIndexOrThrow(MediaColumns.SIZE)
    private val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_ADDED)
    private val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_MODIFIED)
    private val widthColumn = cursor.getColumnIndexOrThrow(MediaColumns.WIDTH)
    private val heightColumn = cursor.getColumnIndexOrThrow(MediaColumns.HEIGHT)
    private val dateTakenColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.DATE_TAKEN)
    } else null
    private val durationColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.DURATION)
    } else null
    private val relativePathColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.RELATIVE_PATH)
    } else null
    private val isPendingColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_PENDING)
    } else null
    private val isTrashedColumn = if (hasApi30Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_TRASHED)
    } else null
    private val isFavoriteColumn = if (hasApi30Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_FAVORITE)
    } else null

    /**
     * Reads the current row, or returns `null` if its media type isn't
     * supported by the plugin.
     */
    fun read(): MediaItemData? {
        val type = cursor.getIntOrNull(mediaTypeColumn)?.let(::mediaTypeOf) ?: return null
        val id = cursor.getLong(idColumn)
        return MediaItemData(
            type = type,
            id = id.toString(),
            // Built on the type's own collection rather than Files, so it
            // matches what the rest of the platform hands out for the item.
            uri = ContentUris.withAppendedId(type.collectionUri, id).toString(),
            name = cursor.getStringOrNull(nameColumn),
            mimeType = cursor.getStringOrNull(mimeTypeColumn),
            sizeInBytes = cursor.getLongOrNull(sizeColumn),
            dateAddedInMillis = cursor.getLongOrNull(dateAddedColumn)?.times(1000),
            dateModifiedInMillis = cursor.getLongOrNull(dateModifiedColumn)?.times(1000),
            dateTakenInMillis = dateTakenColumn?.let { cursor.getLongOrNull(it) },
            width = cursor.getIntOrNull(widthColumn),
            height = cursor.getIntOrNull(heightColumn),
            durationInMillis = durationColumn?.let { cursor.getLongOrNull(it) },
            relativePath = relativePathColumn?.let { cursor.getStringOrNull(it) },
            isPending = isPendingColumn?.let { cursor.getBooleanOrNull(it) },
            isTrashed = isTrashedColumn?.let { cursor.getBooleanOrNull(it) },
            isFavorite = isFavoriteColumn?.let { cursor.getBooleanOrNull(it) },
        )
    }

    companion object {
        // Querying a column the device's MediaStore doesn't have throws, so
        // API-gated columns are only requested where they exist.
        private val hasApi29Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        private val hasApi30Columns = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R

        /**
         * Columns to request for [MediaColumnsReader] on this device.
         */
        val projection: List<String> = buildList {
            add(BaseColumns._ID)
            add(FileColumns.MEDIA_TYPE)
            add(MediaColumns.DISPLAY_NAME)
            add(MediaColumns.MIME_TYPE)
            add(MediaColumns.SIZE)
            add(MediaColumns.DATE_ADDED)
            add(MediaColumns.DATE_MODIFIED)
            add(MediaColumns.WIDTH)
            add(MediaColumns.HEIGHT)
            if (hasApi29Columns) {
                add(MediaColumns.DATE_TAKEN)
                add(MediaColumns.DURATION)
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
