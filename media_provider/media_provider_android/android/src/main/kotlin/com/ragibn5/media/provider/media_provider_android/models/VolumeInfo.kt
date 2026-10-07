package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class VolumeInfo(
    /**
     * Whether this volume is the primary shared/external storage volume.
     * */
    val isPrimary: Boolean,
    /**
     * The filesystem UUID of the volume, obtained from [android.os.storage.StorageVolume.getUuid].
     *
     * > Note: This may not be available when the volume is not mounted, or in case of incompatible
     * > volumes.
     * */
    val uuid: String?,
)