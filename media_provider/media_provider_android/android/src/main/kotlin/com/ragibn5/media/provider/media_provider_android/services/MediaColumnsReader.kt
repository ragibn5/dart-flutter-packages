package com.ragibn5.media.provider.media_provider_android.services

import android.database.Cursor
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.services.MediaColumnsReader.Companion.projection
import java.io.File

/**
 * Reads [MediaItem] values from a cursor over a MediaStore collection.
 *
 * The cursor must have been queried with (at least) [projection].
 */
internal class MediaColumnsReader(
    private val cursor: Cursor,
    private val fileLocationResolver: FileLocationResolver,
    private val uriBuilder: MediaUriBuilder = MediaUriBuilder.DEFAULT,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    private val idColumn = cursor.getColumnIndexOrThrow(BaseColumns._ID)
    private val nameColumn = cursor.getColumnIndexOrThrow(MediaColumns.DISPLAY_NAME)
    private val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE)
    private val sizeColumn = cursor.getColumnIndexOrThrow(MediaColumns.SIZE)
    private val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_ADDED)
    private val dateModifiedColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATE_MODIFIED)
    private val dataColumn = cursor.getColumnIndexOrThrow(MediaColumns.DATA)
    private val volumeNameColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.VOLUME_NAME)
    } else {
        null
    }
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
        val uri = uriBuilder.build(collection.uri, id)
        val volNameNew = volumeNameColumn?.let { cursor.getStringOrNull(it) }
        val relativePathNew = relativePathColumn?.let { cursor.getStringOrNull(it) }
        val mediaFileInfo = readDataFilePath()?.let { fileLocationResolver.resolve(File(it)) }
        return MediaItem(
            type = collection.type,
            id = id.toString(),
            uri = uri,
            name = cursor.getStringOrNull(nameColumn),
            mimeType = cursor.getStringOrNull(mimeTypeColumn),
            sizeInBytes = cursor.getLongOrNull(sizeColumn),
            dateAddedInMillis = cursor.getLongOrNull(dateAddedColumn)?.times(1000),
            dateModifiedInMillis = cursor.getLongOrNull(dateModifiedColumn)?.times(1000),
            volumeName = mediaFileInfo?.volumeName,
            volumeNameNew = volNameNew,
            relativePath = mediaFileInfo?.relativeParentPath,
            relativePathNew = relativePathNew,
            isPending = isPendingColumn?.let(cursor::getBooleanOrNull),
            isTrashed = isTrashedColumn?.let(cursor::getBooleanOrNull),
            isFavorite = isFavoriteColumn?.let(cursor::getBooleanOrNull),
        )
    }

    private val hasApi29Columns: Boolean
        get() = sdkInt >= Build.VERSION_CODES.Q

    private val hasApi30Columns: Boolean
        get() = sdkInt >= Build.VERSION_CODES.R

    private fun readDataFilePath(): String? {
        return dataColumn.let(cursor::getStringOrNull)
    }

    companion object {
        /**
         * Columns to request for [MediaColumnsReader] on a device at [sdkInt].
         */
        @Suppress("DEPRECATION")
        fun projectionFor(sdkInt: Int): List<String> = buildList {
            add(BaseColumns._ID)
            add(MediaColumns.DISPLAY_NAME)
            add(MediaColumns.MIME_TYPE)
            add(MediaColumns.SIZE)
            add(MediaColumns.DATE_ADDED)
            add(MediaColumns.DATE_MODIFIED)
            add(MediaColumns.DATA)

            if (sdkInt >= Build.VERSION_CODES.Q) {
                add(MediaColumns.VOLUME_NAME)
                add(MediaColumns.RELATIVE_PATH)
                add(MediaColumns.IS_PENDING)
            }

            if (sdkInt >= Build.VERSION_CODES.R) {
                add(MediaColumns.IS_TRASHED)
                add(MediaColumns.IS_FAVORITE)
            }
        }

        /**
         * Columns to request for [MediaColumnsReader] on this device.
         */
        val projection: List<String> = projectionFor(Build.VERSION.SDK_INT)
    }
}
