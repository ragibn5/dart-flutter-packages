package com.ragibn5.media.provider.media_provider_android.services

import android.annotation.SuppressLint
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.models.FileLocation
import java.io.File
import java.util.Locale

internal class FileLocationResolver(
    private val storageManager: StorageManager,
    private val volumePathResolver: VolumePathResolver,
) {
    fun resolve(file: File): FileLocation? {
        val volume = storageManager.getStorageVolume(file) ?: return null
        val volumePath = volumePathResolver.resolve(file)?.ensureTrailingSlash() ?: return null
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        return FileLocation(
            volumeName = volume.getStorageVolumeName(),
            relativeParentPath = fileParentPath.substring(volumePath.length),
            fileNameWithExtension = file.name
        )
    }

    /**
     * The `VOLUME_NAME` the platform would report for this volume.
     *
     * [MediaStore.VOLUME_EXTERNAL_PRIMARY] for the primary volume, so a caller
     * cannot tell "primary" from "unknown" the way it could when the primary
     * volume reported `null`. It reads as the same `"external_primary"` the
     * `VOLUME_NAME` column returns, so both spellings agree.
     */
    @SuppressLint("InlinedApi")
    private fun StorageVolume.getStorageVolumeName(): String? {
        return if (isPrimary) MediaStore.VOLUME_EXTERNAL_PRIMARY else uuid?.lowercase(Locale.US)
    }
}