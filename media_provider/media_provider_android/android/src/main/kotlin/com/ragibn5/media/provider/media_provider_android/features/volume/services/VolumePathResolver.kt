package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import java.io.File

internal class VolumePathResolver(
    private val appContext: Context,
    private val storageManager: StorageManager,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    /**
     * Resolves the absolute filesystem root path for a given [android.os.storage.StorageVolume].
     * Returns null if the volume is invalid, disconnected, or unmounted.
     */
    fun resolve(storageVolume: StorageVolume): String? {
        // 1. Modern Android (Android 11 / API 30+) natively exposes the directory file object
        if (sdkInt >= Build.VERSION_CODES.R) {
            @SuppressLint("NewApi")
            return storageVolume.directory?.absolutePath?.ensureNoTrailingSlash()
        }

        // 2. Direct optimization fallback for the primary internal storage volume on legacy APIs
        if (storageVolume.isPrimary) {
            @Suppress("kotlin:S5324")
            return Environment.getExternalStorageDirectory().absolutePath.ensureNoTrailingSlash()
        }

        // 3. Clean native resolution for secondary external volumes (API 24 to 29)
        val uuid = storageVolume.uuid ?: return null
        return getVolumePathViaStorageManager(uuid)?.ensureNoTrailingSlash()
    }

    /**
     * Loops through valid app sandboxes and asks the StorageManager to identify
     * which exact volume owns that folder by matching UUIDs. Fully safe down to
     * API 24 since getStorageVolume(File) is native.
     */
    private fun getVolumePathViaStorageManager(targetUuid: String): String? {
        // Gather all active paths safely provisioned by the framework sandbox
        @Suppress("kotlin:S5324")
        val activeDirs = appContext.getExternalFilesDirs(null)
            .filterNotNull()

        for (dir in activeDirs) {
            // Native platform call (Available since API 24)
            val volumeForDir = storageManager.getStorageVolume(dir)

            // Strictly match the volume by its system token identity
            if (volumeForDir != null && volumeForDir.uuid == targetUuid) {
                return dir.absolutePath.trimToVolumeRoot()
            }
        }

        return null
    }

    /**
     * Safely strips away the OS-mandated app sandbox directory tree to perfectly isolate
     * the raw storage volume root.
     */
    private fun String.trimToVolumeRoot(): String {
        // Search for the exact system block sequence delimiter
        val sandboxMarker = "${File.separator}Android${File.separator}data"
        val markerIndex = this.indexOf(sandboxMarker, ignoreCase = true)
        return if (markerIndex != -1) {
            this.substring(0, markerIndex)
        } else {
            // Ultimate structural fallback wrapper if string structure is mutated
            this.ensureNoTrailingSlash()
        }
    }
}