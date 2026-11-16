package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes

/**
 * Reads the MIME type of `MediaStore` items from their provider.
 */
internal class MediaMimeTypeResolver(
    private val contentResolver: ContentResolver,
) {
    /**
     * The MIME type of the item at [uri].
     *
     * @param uri the item's `content://` URI.
     * @return the type, or `null` if the provider doesn't know it.
     * @throws MediaProviderException with
     * [MediaActionExceptionCodes.INVALID_REQUEST] if [uri] isn't a valid item
     * URI.
     */
    fun resolve(uri: Uri): String? {
        try {
            return contentResolver.getType(uri)
        } catch (e: IllegalArgumentException) {
            throw MediaProviderException(
                MediaActionExceptionCodes.INVALID_REQUEST,
                e.message ?: "The content uri is not a valid media item uri",
                details = mapOf("uri" to uri.toString()),
                cause = e
            )
        }
    }

    companion object {
        /** The MIME type that matches any type, for items of unknown type. */
        const val ANY_MIME_TYPE = "*/*"
    }
}
