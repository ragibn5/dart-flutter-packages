package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A single media file tracked by the Android `MediaStore`, together with the metadata the
 * platform exposes for it.
 *
 * Every field maps directly to a `MediaStore` column. Values are read once when the item is
 * queried and are not kept in sync with later changes made to the underlying file.
 *
 * Unless documented otherwise, every field is nullable: a property is `null` when the value is
 * absent, when the corresponding column was not requested, or when the device does not report it
 * (for example on an API level older than the one that introduced the column).
 *
 * @see MediaType
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
)
