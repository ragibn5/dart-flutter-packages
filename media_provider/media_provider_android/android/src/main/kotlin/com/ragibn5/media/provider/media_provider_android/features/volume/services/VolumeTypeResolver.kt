package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.storage.StorageVolume
import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType

internal class VolumeTypeResolver {
    fun resolve(volume: StorageVolume): VolumeType =
        resolve(volume.isPrimary, volume.isRemovable, readBlockMajor(volume))

    /**
     * Classify a volume from the facts read off it.
     *
     * Split out from [resolve] because the block major only ever comes from the
     * hidden `getId`, which no test double can supply.
     */
    @VisibleForTesting
    internal fun resolve(isPrimary: Boolean, isRemovable: Boolean, blockMajor: Int?): VolumeType {
        if (isPrimary) return VolumeType.PRIMARY
        if (!isRemovable) return VolumeType.UNKNOWN
        return when (blockMajor) {
            MAJOR_MMC -> VolumeType.SD_CARD
            MAJOR_SCSI_DISK -> VolumeType.USB_DRIVE
            else -> VolumeType.UNKNOWN_REMOVABLE
        }
    }

    /**
     * Pull the block major out of a volume id like `public:179,65`.
     *
     * Null for anything that is not such an id.
     * */
    @VisibleForTesting
    internal fun parseBlockMajor(id: String?): Int? {
        id ?: return null
        return PUBLIC_ID_REGEX.matchEntire(id)?.groupValues?.get(1)?.toIntOrNull()
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
    private fun readBlockMajor(volume: StorageVolume): Int? =
        parseBlockMajor(runCatching { getIdMethod?.invoke(volume) as? String }.getOrNull())

    companion object {
        // Linux block-device major number: mmcblk*, SD cards
        @VisibleForTesting
        internal const val MAJOR_MMC = 179

        // Linux block-device major number: sd*, USB mass storage
        @VisibleForTesting
        internal const val MAJOR_SCSI_DISK = 8

        // Matches ids like "public:179,65"
        private val PUBLIC_ID_REGEX = Regex("""public:(\d+),(\d+)""")
    }
}