package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentUris
import android.net.Uri

/**
 * Builds the `content://` URI of a single `MediaStore` row.
 *
 * [MediaColumnsReader] and [MediaStoreServiceImpl] depend on this instead of
 * reaching for `ContentUris` themselves.
 */
internal fun interface MediaUriBuilder {
    /**
     * The URI of row [id] in [collection], as sent to Dart.
     */
    fun build(collection: Uri, id: Long): String

    companion object {
        /**
         * Addresses rows the way `ContentUris` does on a device.
         */
        val DEFAULT: MediaUriBuilder = MediaUriBuilder { collection, id ->
            ContentUris.withAppendedId(collection, id).toString()
        }
    }
}