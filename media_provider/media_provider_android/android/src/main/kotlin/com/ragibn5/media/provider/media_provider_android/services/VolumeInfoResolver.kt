package com.ragibn5.media.provider.media_provider_android.services

import android.annotation.SuppressLint
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.models.StorageVolumeSpec
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import java.util.Locale

internal class VolumeInfoResolver(
    private val storageManager: StorageManager,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    fun toName(spec: StorageVolumeSpec): String? {
        if (spec.isPrimary) {
            return storageManager.primaryStorageVolume.getStorageVolumeName()
        }
        return storageManager.storageVolumes
            .firstOrNull { it.uuid.equals(spec.uuid, ignoreCase = true) }
            ?.getStorageVolumeName()
    }

    fun fromName(volumeName: String): VolumeInfo? {
        return storageManager.storageVolumes
            .firstOrNull { it.getStorageVolumeName() == volumeName }
            ?.let { VolumeInfo(it.isPrimary, it.uuid) }
    }

    private fun StorageVolume.getStorageVolumeName(): String? {
        return if (sdkInt >= Build.VERSION_CODES.R) {
            @SuppressLint("NewApi")
            mediaStoreVolumeName
        } else {
            @SuppressLint("InlinedApi")
            if (isPrimary) MediaStore.VOLUME_EXTERNAL else normalizeUuid(uuid)
        }
    }

    /**
     * This is a fallback workaround.
     * Make sure to check this if your target android sdk version changes.
     * */
    private fun normalizeUuid(fsUuid: String?): String? {
        return fsUuid?.lowercase(Locale.US)
    }
}