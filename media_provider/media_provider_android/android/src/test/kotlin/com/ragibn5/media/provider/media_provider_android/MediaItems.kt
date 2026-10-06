package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaType

/**
 * Media as the plugin is expected to report it.
 *
 * These are the same items the service tests read out of a cursor, so a reply
 * that survives the round trip can be compared against them.
 */
internal fun photoItem(
    id: Long = 1,
    name: String = "cat.jpg",
): MediaItem = MediaItem(
    type = MediaType.PHOTO,
    id = id.toString(),
    uri = "content://media/external/images/media/$id",
    name = name,
    mimeType = "image/jpeg",
    sizeInBytes = 2048,
    dateAddedInMillis = 1_700_000_000_000,
    dateModifiedInMillis = 1_700_000_100_000,
    dateTakenInMillis = 1_700_000_100_000,
    volumeName = "primary",
    relativePath = "DCIM/Camera/",
    ownerPackageName = "com.android.camera",
    isPending = false,
    isTrashed = false,
    isFavorite = true,
    isDownloaded = false,
)

/**
 * A video whose every nullable column is NULL, to keep it distinct from
 * [photoItem] in assertions.
 */
internal fun videoItem(
    id: Long = 2,
    name: String = "dog.mp4",
): MediaItem = MediaItem(
    type = MediaType.VIDEO,
    id = id.toString(),
    uri = "content://media/external/video/media/$id",
    name = name,
    mimeType = "video/mp4",
    sizeInBytes = null,
    dateAddedInMillis = null,
    dateModifiedInMillis = null,
    dateTakenInMillis = null,
    volumeName = null,
    relativePath = null,
    ownerPackageName = null,
    isPending = null,
    isTrashed = null,
    isFavorite = null,
    isDownloaded = null,
)
