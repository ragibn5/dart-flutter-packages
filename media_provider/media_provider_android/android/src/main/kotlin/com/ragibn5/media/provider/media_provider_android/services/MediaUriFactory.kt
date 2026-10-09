package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.MediaQueryRequest
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.StorageVolumeSpec

/**
 * Builds the `MediaStore` uri for a [MediaType] on a [StorageVolumeSpec].
 *
 * Returns `null` if the volume is not present on the device.
 */
internal class MediaUriFactory(
    private val volumeInfoResolver: VolumeInfoResolver,
) {
    fun create(type: MediaType, volume: StorageVolumeSpec): Uri? {
        val volumeName = volumeInfoResolver.toName(volume) ?: return null
        return when (type) {
            MediaType.PHOTO -> MediaStore.Images.Media.getContentUri(volumeName)
            MediaType.VIDEO -> MediaStore.Video.Media.getContentUri(volumeName)
        }
    }
}