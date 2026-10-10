package com.ragibn5.media.provider.media_provider_android.services

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
    fun resolve(storageVolume: StorageVolume): String? {
        if (sdkInt >= Build.VERSION_CODES.R) {
            @SuppressLint("NewApi")
            return storageVolume.directory?.absolutePath
        }

        if (storageVolume.isPrimary) {
            return Environment.getExternalStorageDirectory().absolutePath
        }

        val uuid = storageVolume.uuid ?: return null
        return getVolumePath(uuid)?.ensureNoTrailingSlash()
    }

    private fun getVolumePath(uuid: String): String? {
        val volumeRoots = appContext.getExternalFilesDirs(null)
            .map { it.absolutePath.trimToVolumeRoot(true) }
        val rootsToVolumeMap = volumeRoots
            .associateWith { storageManager.getStorageVolume(File(it)) }
        return rootsToVolumeMap.entries.firstOrNull { it.value?.uuid == uuid }?.key
    }

    private fun String.trimToVolumeRoot(absolute: Boolean): String {
        val prefix = if (absolute) File.separator else ""
        return prefix + this.split(File.separator)
            .filter { it.isNotEmpty() }
            .dropLast(4)
            .joinToString(File.separator)
    }
}