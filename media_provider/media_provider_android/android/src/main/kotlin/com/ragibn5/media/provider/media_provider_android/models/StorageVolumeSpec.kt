package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A storage volume media can be searched on.
 *
 * Matches a volume reported by [android.provider.MediaStore.getExternalVolumeNames].
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class StorageVolumeSpec(
    /**
     * Whether this volume is the primary shared/external storage volume.
     * */
    val isPrimary: Boolean,
    /**
     * The filesystem UUID of the volume.
     *
     * > Note:
     * > - For non-primary external volumes, this is always non-null.
     * > - For primary volume, this field is not relevant and not used.
     * */
    val uuid: String?,
) {
    init {
        require(isPrimary || uuid != null) {
            "uuid must be non-null for non-primary volumes"
        }
    }

    companion object {
        /**
         * The primary shared/external storage volume.
         */
        fun primary(): StorageVolumeSpec =
            StorageVolumeSpec(isPrimary = true, uuid = null)

        /**
         * A secondary external volume, identified by its filesystem [uuid].
         */
        fun external(uuid: String): StorageVolumeSpec =
            StorageVolumeSpec(isPrimary = false, uuid = uuid)
    }
}