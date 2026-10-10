package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.models.VolumeSpec

/**
 * Expands a [QuerySpec] into the individual [MediaQuery]s it asks for.
 *
 * Volumes which are not present on the device are skipped, so an empty result
 * means no requested volume exists.
 */
internal class MediaQueryBuilder(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
) {
    fun build(request: QuerySpec): List<MediaQuery> = buildList {
        request.types.forEach { type ->
            request.volumes.forEach { volume ->
                buildFor(type, volume)?.run { add(this) }
            }
        }
    }

    private fun buildFor(type: MediaType, volume: VolumeSpec): MediaQuery? {
        val volume = volume.mediaStoreVolume() ?: return null
        return MediaQuery(
            type = type,
            uri = type.toCollectionUri(),
            selection = "${MediaStore.MediaColumns.DATA} LIKE ?",
            selectionArgs = arrayOf("${volumePathResolver.resolve(volume)}%")
        )
    }

    private fun MediaType.toCollectionUri(): Uri {
        return when (this) {
            MediaType.PHOTO -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            MediaType.VIDEO -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }
    }

    private fun VolumeSpec.mediaStoreVolume(): StorageVolume? {
        return when (this) {
            VolumeSpec.Primary -> storageManager.primaryStorageVolume
            is VolumeSpec.External ->
                storageManager.storageVolumes
                    .firstOrNull { it.uuid == uuid }
        }
    }
}
