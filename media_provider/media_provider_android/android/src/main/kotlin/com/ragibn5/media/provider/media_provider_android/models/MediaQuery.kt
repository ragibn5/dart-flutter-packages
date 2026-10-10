package com.ragibn5.media.provider.media_provider_android.models

import android.net.Uri

internal data class MediaQuery(
    val type: MediaType,
    val uri: Uri,
    val selection: String?,
    val selectionArgs: Array<String>?,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is MediaQuery) return false

        return type == other.type &&
                uri == other.uri &&
                selection == other.selection &&
                selectionArgs.contentEquals(other.selectionArgs)
    }

    override fun hashCode(): Int {
        var result = type.hashCode()
        result = 31 * result + uri.hashCode()
        result = 31 * result + (selection?.hashCode() ?: 0)
        result = 31 * result + (selectionArgs?.contentHashCode() ?: 0)
        return result
    }
}
