package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * A storage volume media can be searched on.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal sealed interface VolumeSpec {
    /**
     * The primary shared/external storage volume.
     *
     * Has no UUID: the primary volume is usually emulated storage and is
     * addressed through [android.provider.MediaStore.VOLUME_EXTERNAL_PRIMARY].
     */
    @Serializable
    @SerialName("primary")
    data object Primary : VolumeSpec

    /**
     * A secondary external volume (SD card, USB storage), identified by its
     * filesystem [uuid].
     *
     * @property uuid The filesystem UUID of the volume, in the `XXXX-XXXX` form
     * reported by the system. Case is not significant here; it is lowercased
     * when converted to a MediaStore volume name.
     */
    @Serializable
    @SerialName("external")
    data class External(val uuid: String) : VolumeSpec
}