package com.ragibn5.media.provider.media_provider_android.features.volume.models


import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class VolumeIdentity(
    /**
     * Whether this is the primary shared/external storage volume.
     */
    val isPrimary: Boolean,

    /**
     * Whether this storage volume is removable.
     */
    val isRemovable: Boolean,

    /**
     * Whether this storage volume is emulated.
     */
    val isEmulated: Boolean,

    /**
     * The type of the volume.
     */
    val type: VolumeType,

    /**
     * The total capacity of the volume, in bytes.
     *
     * Can be zero if the capacity could not be read.
     */
    val capacityInBytes: Long,

    /**
     * The filesystem UUID of the volume, obtained from [android.os.storage.StorageVolume.getUuid].
     *
     * > Note: This may not be available when the volume is not mounted, or in case of incompatible
     * > volumes.
     */
    val uuid: String?,
)