package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A `MediaStore` item of any type.
 *
 * Mirrors `MediaStore.MediaColumns`, which every collection shares.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaItemData(
    /**
     * Which collection the item comes from.
     */
    val type: MediaType,

    /**
     * `MediaStore` row ID.
     *
     * Unique within its collection.
     */
    val id: String,

    /**
     * `content://` URI for opening the item through `ContentResolver`.
     */
    val uri: String,

    /**
     * File name, including extension.
     *
     * Read from `DISPLAY_NAME`. `null` if unknown.
     */
    val name: String?,

    /**
     * MIME type, e.g. `image/jpeg`.
     *
     * `null` if unknown.
     */
    val mimeType: String?,

    /**
     * File size in bytes.
     *
     * `null` if unknown.
     */
    val sizeInBytes: Long?,

    /**
     * When the item was added to `MediaStore`, in milliseconds since epoch.
     *
     * Converted from `DATE_ADDED`, which is in seconds. `null` if unknown.
     */
    val dateAddedInMillis: Long?,

    /**
     * When the file was last modified, in milliseconds since epoch.
     *
     * Converted from `DATE_MODIFIED`, which is in seconds. `null` if unknown.
     */
    val dateModifiedInMillis: Long?,

    /**
     * When the media was captured, in milliseconds since epoch.
     *
     * `null` if unknown or unsupported by the device (below API 29).
     */
    val dateTakenInMillis: Long?,

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
     * Playback duration in milliseconds.
     *
     * `null` if unknown or unsupported by the device (below API 29).
     */
    val durationInMillis: Long?,

    /**
     * Directory relative to the storage volume root, e.g. `DCIM/Camera/`.
     *
     * `null` if unsupported by the device (below API 29).
     */
    val relativePath: String?,

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
