package com.ragibn5.media.provider.media_provider_android.testing

import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeState
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType

/** The primary volume, as the plugin reports it. */
internal val primaryVolumeIdentity = VolumeIdentity(
    uuid = null,
    type = VolumeType.PRIMARY,
    volumePath = "/storage/emulated/0",
    capacityInBytes = 128_000_000_000,
    isPrimary = true,
    isRemovable = false,
    isEmulated = true,
)

/** An SD card, as the plugin reports it. */
internal val sdCardVolumeIdentity = VolumeIdentity(
    uuid = "1A2B-3C4D",
    type = VolumeType.SD_CARD,
    volumePath = "/storage/1A2B-3C4D",
    capacityInBytes = 32_000_000_000,
    isPrimary = false,
    isRemovable = true,
    isEmulated = false,
)

/** A mounted volume with [identity]. */
internal fun mountedVolume(identity: VolumeIdentity) = VolumeInfo(
    identity = identity,
    state = VolumeState.MOUNTED,
    availableSpaceInBytes = 1_000,
    documentsRootUri = null,
)
