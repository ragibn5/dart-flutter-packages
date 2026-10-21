package com.ragibn5.media.provider.media_provider_android.features.media.models

internal interface MediaColumnProperties {
    /**
     * The `MediaStore` row ID, as a string.
     *
     * Sourced from `BaseColumns._ID`, held as a string rather than a number.
     */
    val id: String

    /**
     * The display name of the file, including its extension, for example `IMG_0001.jpg`.
     *
     * Sourced from `MediaStore.MediaColumns.DISPLAY_NAME`. `null` when the row carries no name.
     */
    val name: String?

    /**
     * The MIME type of the file, for example `image/jpeg`.
     *
     * Sourced from `MediaStore.MediaColumns.MIME_TYPE`. `null` when `MediaStore` has not
     * determined one for the file.
     */
    val mimeType: String?

    /**
     * The size of the file, in bytes, for example `2048`.
     *
     * Sourced from `MediaStore.MediaColumns.SIZE`. `null` when the row reports no size.
     */
    val sizeInBytes: Long?

    /**
     * The time the item was added to the media library, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_ADDED`, which is expressed in seconds.
     * `null` when the row carries no value.
     */
    val dateAddedInMillis: Long?

    /**
     * The time the file was last modified, in milliseconds since the Unix epoch.
     *
     * Converted from `MediaStore.MediaColumns.DATE_MODIFIED`, which is expressed in seconds.
     * `null` when the row carries no value.
     */
    val dateModifiedInMillis: Long?

    /**
     * The time the item was captured, in milliseconds since the Unix epoch.
     *
     * Sourced from `MediaStore.MediaColumns.DATE_TAKEN`. `null` below API level 29 (Q), and `null`
     * when the file has no recorded capture time.
     */
    val dateTakenInMillis: Long?

    /**
     * The package name of the app that owns the item, for example `com.android.camera`.
     *
     * Sourced from `MediaStore.MediaColumns.OWNER_PACKAGE_NAME`. `null` below API level 29 (Q),
     * and `null` when the item is not owned by any app.
     */
    val ownerPackageName: String?

    /**
     * The raw data backing this media.
     *
     * Sourced from `MediaStore.MediaColumns.DATA`. `null` when the row carries no data.
     *
     * Note: For file backed media, this is the path to the file. For content backed media,
     * this can be the corresponding raw data, or null.
     */
    val data: String?

    /**
     * Whether the item is currently being written and is not yet ready to be opened.
     *
     * Sourced from `MediaStore.MediaColumns.IS_PENDING`. `null` below API level 29 (Q).
     */
    val isPending: Boolean?

    /**
     * Whether the item has been moved to the trash and is therefore no longer visible in the
     * collection it was queried from.
     *
     * Sourced from `MediaStore.MediaColumns.IS_TRASHED`. `null` below API level 30 (R).
     */
    val isTrashed: Boolean?

    /**
     * Whether the item is marked as a favorite.
     *
     * Sourced from `MediaStore.MediaColumns.IS_FAVORITE`. `null` below API level 30 (R).
     */
    val isFavorite: Boolean?

    /**
     * Whether the item belongs to the Downloads collection.
     *
     * Sourced from `MediaStore.MediaColumns.IS_DOWNLOAD`. `null` below API level 30 (R).
     */
    val isDownloaded: Boolean?
}