package com.ragibn5.media.provider.media_provider_android.models

```kotlin
package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A media item managed by `MediaStore`.
 *
 * Contains metadata shared across supported media collections.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaItem(
    /**
     * Which collection the item comes from.
     */
    val type: MediaType,

    /**
     * `MediaStore` row ID.
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
     * When the item was added to the device's media library, in milliseconds since epoch.
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
```
