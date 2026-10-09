package com.ragibn5.media.provider.media_provider_android.services

import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.MediaQueryRequest

/**
 * Expands a [MediaQueryRequest] into the individual [MediaQuery]s it asks for.
 *
 * Volumes which are not present on the device are skipped, so an empty result
 * means no requested volume exists.
 */
internal class MediaStoreQueryBuilder(
    private val mediaUriFactory: MediaUriFactory,
) {
    fun build(request: MediaQueryRequest): List<MediaQuery> = buildList {
        request.types.forEach { type ->
            request.volumes.forEach { volume ->
                val uri = mediaUriFactory.create(type, volume) ?: return@forEach
                add(
                    MediaQuery(
                        type = type,
                        uri = uri,
                        selection = null,
                        selectionArgs = null,
                    )
                )
            }
        }
    }
}
