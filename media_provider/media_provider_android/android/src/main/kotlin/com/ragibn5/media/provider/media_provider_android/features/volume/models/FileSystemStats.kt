package com.ragibn5.media.provider.media_provider_android.features.volume.models

internal data class FileSystemStats(
    /**
     * The total size of the filesystem, in bytes.
     */
    val capacityInBytes: Long,

    /**
     * The space still available on the filesystem, in bytes.
     */
    val availableSpaceInBytes: Long,
)