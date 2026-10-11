package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class VolumeInfo(
    /**
     * The identity of a volume.
     *
     * See [VolumeIdentity] for more info.
     * */
    val identity: VolumeIdentity,

    /**
     * The state of the volume.
     * */
    val state: VolumeState,

    /**
     * The space still available on the volume, in bytes.
     *
     * Can be zero if the availability could not be read.
     */
    val availableSpaceInBytes: Long,
)