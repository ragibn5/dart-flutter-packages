package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A single media file tracked by the Android `MediaStore`.
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
     * Combined with [type] and [volumeName], this identifies the underlying file across mounts.
     */
    val id: String,

    /**
     * The `content://` URI used to open the item through `ContentResolver`.
     */
    val uri: String,

    /**
     * The display name of the file, including its extension.
     *
     * Sourced from `MediaStore.MediaColumns.DISPLAY_NAME`.
     */
    val name: String?,

    /**
     * The MIME type of the file, for example `image/jpeg`.
     *
     * Sourced from `MediaStore.MediaColumns.MIME_TYPE`.
     */
    val mimeType: String?,

    /**
     * The size of the file, in bytes.
     *
     * Sourced from `MediaStore.MediaColumns.SIZE`.
     */
    val sizeInBytes: Long?,

    /**
     * The time the item was added to the media library, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_ADDED`, which is expressed in seconds.
     */
    val dateAddedInMillis: Long?,

    /**
     * The time the file was last modified, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_MODIFIED`, which is expressed in seconds.
     */
    val dateModifiedInMillis: Long?,

    /**
     * The time the item was captured, in milliseconds since the Unix epoch.
     *
     * Unlike [dateAddedInMillis] and [dateModifiedInMillis], `DATE_TAKEN` is
     * already expressed in milliseconds, so no conversion happens here.
     *
     * Sourced from `MediaStore.MediaColumns.DATE_TAKEN`. `null` below API level 29 (Q).
     */
    val dateTakenInMillis: Long?,

    /**
     * The name of the storage volume holding the file.
     *
     * - `external_primary` for the primary shared storage volume.
     * - The lowercased volume UUID for secondary shared storage volumes.
     * - `null` if the volume cannot be resolved.
     */
    val volumeName: String?,

    /**
     * The path of the directory containing the file, relative to the root of its storage volume,
     * for example `DCIM/Camera/`.
     *
     * Sourced from `MediaStore.MediaColumns.RELATIVE_PATH`. Empty when the file sits directly in
     * the volume root, `null` when the value is unknown.
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
