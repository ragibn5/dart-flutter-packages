package com.ragibn5.media.provider.media_provider_android.services

import android.database.Cursor
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.extensions.getBooleanOrNull
import com.ragibn5.media.provider.media_provider_android.extensions.getLongOrNull
import com.ragibn5.media.provider.media_provider_android.extensions.getStringOrNull
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollection
import java.io.File

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
    private val dateTakenColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.DATE_TAKEN)
    } else {
        null
    }
    private val ownerPackageNameColumn = if (hasApi29Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.OWNER_PACKAGE_NAME)
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
    private val isDownloadedColumn = if (hasApi30Columns) {
        cursor.getColumnIndexOrThrow(MediaColumns.IS_DOWNLOAD)
    } else {
        null
    }

    fun read(collection: MediaStoreCollection): MediaItem {
        val id = cursor.getLong(idColumn)
        val uri = uriBuilder.build(collection.uri, id)
        val filePath = cursor.getStringOrNull(dataColumn)
        val mediaFileInfo = filePath?.let { fileLocationResolver.resolve(File(it)) }
        return MediaItem(
            type = collection.type,
            id = id.toString(),
            uri = uri,
            name = cursor.getStringOrNull(nameColumn),
            mimeType = cursor.getStringOrNull(mimeTypeColumn),
            sizeInBytes = cursor.getLongOrNull(sizeColumn),
            dateAddedInMillis = cursor.getLongOrNull(dateAddedColumn)?.times(1000),
            dateModifiedInMillis = cursor.getLongOrNull(dateModifiedColumn)?.times(1000),
            dateTakenInMillis = dateTakenColumn?.let(cursor::getLongOrNull),
            volumeName = volumeNameColumn?.let(cursor::getStringOrNull)
                ?: mediaFileInfo?.volumeName,
            relativePath = relativePathColumn?.let(cursor::getStringOrNull)
                ?: mediaFileInfo?.relativeParentPath,
            ownerPackageName = ownerPackageNameColumn?.let(cursor::getStringOrNull),
            isPending = isPendingColumn?.let(cursor::getBooleanOrNull),
            isTrashed = isTrashedColumn?.let(cursor::getBooleanOrNull),
            isFavorite = isFavoriteColumn?.let(cursor::getBooleanOrNull),
            isDownloaded = isDownloadedColumn?.let(cursor::getBooleanOrNull),
        )
    }

    private val hasApi29Columns: Boolean
        get() = sdkInt >= Build.VERSION_CODES.Q

    private val hasApi30Columns: Boolean
        get() = sdkInt >= Build.VERSION_CODES.R

    companion object {
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
                add(MediaColumns.DATE_TAKEN)
                add(MediaColumns.OWNER_PACKAGE_NAME)
            }

            if (sdkInt >= Build.VERSION_CODES.R) {
                add(MediaColumns.IS_TRASHED)
                add(MediaColumns.IS_FAVORITE)
                add(MediaColumns.IS_DOWNLOAD)
            }
        }

        val projection: List<String> = projectionFor(Build.VERSION.SDK_INT)
    }
}

internal class MediaColumnsReaderFactory(
    private val fileLocationResolver: FileLocationResolver,
    private val uriBuilder: MediaUriBuilder = MediaUriBuilder.DEFAULT,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    fun create(cursor: Cursor): MediaColumnsReader =
        MediaColumnsReader(
            cursor = cursor,
            fileLocationResolver = fileLocationResolver,
            uriBuilder = uriBuilder,
            sdkInt = sdkInt,
        )
}
