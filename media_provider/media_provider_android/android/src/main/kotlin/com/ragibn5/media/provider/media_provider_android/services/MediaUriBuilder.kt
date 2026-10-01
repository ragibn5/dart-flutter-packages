package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentUris
import android.net.Uri

internal fun interface MediaUriBuilder {
    fun build(collection: Uri, id: Long): String

    companion object {
        val DEFAULT: MediaUriBuilder = MediaUriBuilder { collection, id ->
            ContentUris.withAppendedId(collection, id).toString()
        }
    }
}