package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A single media file tracked by the Android `MediaStore`.
 *
 * Fields here (most of them, unless noted) corresponds to a column defined in
 * [android.provider.MediaStore.MediaColumns]. See the documentation of that class
 * for more information about each field's possible values. If any field's behavior
 * deviates from the corresponding column documentation, it is explicitly documented
 * here, in the field's documentation.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaItem(
    /**
     * The `MediaStore` collection this item belongs to.
     */
    val type: MediaType,

    /**
     * The `MediaStore` row ID, as a string.
     *
     * Sourced from `BaseColumns._ID`, held as a string rather than a number.
     */
    val id: String,

    /**
     * The `content://` URI used to open the item through `ContentResolver`.
     */
    val uri: String,

    /**
     * The display name of the file, including its extension, for example `IMG_0001.jpg`.
     *
     * Sourced from `MediaStore.MediaColumns.DISPLAY_NAME`. `null` when the row carries no name.
     */
    val name: String?,

    /**
     * The MIME type of the file, for example `image/jpeg`.
     *
     * Sourced from `MediaStore.MediaColumns.MIME_TYPE`. `null` when `MediaStore` has not
     * determined one for the file.
     */
    val mimeType: String?,

    /**
     * The size of the file, in bytes, for example `2048`.
     *
     * Sourced from `MediaStore.MediaColumns.SIZE`. `null` when the row reports no size.
     */
    val sizeInBytes: Long?,

    /**
     * The time the item was added to the media library, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_ADDED`, which is expressed in seconds.
     * `null` when the row carries no value.
     */
    val dateAddedInMillis: Long?,

    /**
     * The time the file was last modified, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_MODIFIED`, which is expressed in seconds.
     * `null` when the row carries no value.
     */
    val dateModifiedInMillis: Long?,

    /**
     * The time the item was captured, in milliseconds since the Unix epoch.
     *
     * Sourced from `MediaStore.MediaColumns.DATE_TAKEN`. `null` below API level 29 (Q), and `null`
     * when the file has no recorded capture time.
     */
    val dateTakenInMillis: Long?,

    /**
     * The storage volume holding the file.
     *
     * Null when the volume cannot be resolved.
     */
    val volumeInfo: VolumeInfo?,

    /**
     * The path of the directory containing the file, relative to the root of its storage volume,
     * for example `DCIM/Camera/`.
     *
     * Possible values:
     * - When the file sits directly in the volume root, it is an empty string.
     * - When not within the volume root, it always ends with a path separator.
     * - `null` when the path cannot be resolved.
     */
    val relativePath: String?,

    /**
     * The package name of the app that owns the item, for example `com.android.camera`.
     *
     * Sourced from `MediaStore.MediaColumns.OWNER_PACKAGE_NAME`. `null` below API level 29 (Q),
     * and `null` when the item is not owned by any app.
     */
    val ownerPackageName: String?,

    /**
     * Whether the item is currently being written and is not yet ready to be opened.
     *
     * Sourced from `MediaStore.MediaColumns.IS_PENDING`. `null` below API level 29 (Q).
     */
    val isPending: Boolean?,

    /**
     * Whether the item has been moved to the trash and is therefore no longer visible in the
     * collection it was queried from.
     *
     * Sourced from `MediaStore.MediaColumns.IS_TRASHED`. `null` below API level 30 (R).
     */
    val isTrashed: Boolean?,

    /**
     * Whether the item is marked as a favorite.
     *
     * Sourced from `MediaStore.MediaColumns.IS_FAVORITE`. `null` below API level 30 (R).
     */
    val isFavorite: Boolean?,

    /**
     * Whether the item belongs to the Downloads collection.
     *
     * Sourced from `MediaStore.MediaColumns.IS_DOWNLOAD`. `null` below API level 30 (R).
     */
    val isDownloaded: Boolean?,
)
