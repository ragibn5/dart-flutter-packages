package com.ragibn5.media.provider.media_provider_android.services

import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.models.VolumeType

internal object VolumeTypeResolver {
    // Linux block-device major number: mmcblk*, SD cards
    private const val MAJOR_MMC = 179

    // Linux block-device major number: sd*, USB mass storage
    private const val MAJOR_SCSI_DISK = 8

    // Matches ids like "public:179,65"
    private val publicIdRegex = Regex("""public:(\d+),(\d+)""")

    fun resolve(volume: StorageVolume): VolumeType {
        if (volume.isPrimary) return VolumeType.PRIMARY
        if (!volume.isRemovable) return VolumeType.UNKNOWN
        return when (readBlockMajor(volume)) {
            MAJOR_MMC -> VolumeType.SD_CARD
            MAJOR_SCSI_DISK -> VolumeType.USB_DRIVE
            else -> VolumeType.UNKNOWN_REMOVABLE
        }
    }

    /**
     * Read the hidden `getId` method.
     *
     * Null if the platform blocks or lacks it.
     * */
    private val getIdMethod by lazy {
        runCatching { StorageVolume::class.java.getMethod("getId") }.getOrNull()
    }

    /**
     * Derive the block major from system.
     *
     * Null if it was not possible derive the id, or if it was unknown.
     * */
    private fun readBlockMajor(volume: StorageVolume): Int? {
        val id = runCatching { getIdMethod?.invoke(volume) as? String }.getOrNull()
            ?: return null
        return publicIdRegex.matchEntire(id)?.groupValues?.get(1)?.toIntOrNull()
    }
}