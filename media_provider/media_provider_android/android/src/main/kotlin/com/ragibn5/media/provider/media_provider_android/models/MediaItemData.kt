package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A media file indexed by `MediaStore`.
 *
 * Sent to Dart as JSON, where it maps to the Dart `MediaItem` class.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaItemData(
    /**
     * `MediaStore` row ID.
     *
     * Unique within its collection.
     */
    val id: String,

    /**
     * File name, including extension.
     *
     * Read from `DISPLAY_NAME`.
     */
    val name: String,

    /**
     * MIME type, e.g. `image/jpeg`.
     */
    val mimeType: String,

    /**
     * File size in bytes.
     */
    val sizeInBytes: Long,

    /**
     * When the item was added to `MediaStore`, in milliseconds since epoch.
     *
     * Converted from `DATE_ADDED`, which is in seconds.
     */
    val dateAddedInMillis: Long,

    /**
     * When the file was last modified, in milliseconds since epoch.
     *
     * Converted from `DATE_MODIFIED`, which is in seconds.
     */
    val dateModifiedInMillis: Long,

    /**
     * When the media was captured (usually from EXIF), in milliseconds since epoch.
     *
     * `null` if unknown.
     */
    val dateTakenInMillis: Long?,

    /**
     * `content://` URI for opening the item through `ContentResolver`.
     */
    val uri: String,

    /**
     * Directory relative to the storage volume root, e.g. `DCIM/Camera/`.
     *
     * `null` if unsupported by the device (below API 29).
     */
    val relativePath: String?,

    /**
     * Width in pixels.
     *
     * `null` if unknown.
     */
    val width: Int?,

    /**
     * Height in pixels.
     *
     * `null` if unknown.
     */
    val height: Int?,

    /**
     * Playback duration in milliseconds, for video and audio.
     *
     * `null` for images.
     */
    val durationInMillis: Long?,

    /**
     * Whether the item is still being written.
     *
     * `null` if unsupported by the device (below API 29).
     */
    val isPending: Boolean?,

    /**
     * Whether the item is in the trash.
     *
     * `null` if unsupported by the device (below API 30).
     */
    val isTrashed: Boolean?,

    /**
     * Whether the item is marked as favorite.
     *
     * `null` if unsupported by the device (below API 30).
     */
    val isFavorite: Boolean?,
)