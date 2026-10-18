package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentUris
import android.net.Uri

internal object MediaItemUriBuilder {
    fun build(collection: Uri, id: Long): String {
        return ContentUris.withAppendedId(collection, id).toString()
    }
}