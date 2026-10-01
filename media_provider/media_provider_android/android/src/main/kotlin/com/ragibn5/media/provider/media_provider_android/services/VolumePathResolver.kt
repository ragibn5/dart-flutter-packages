package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import androidx.annotation.RequiresApi
import java.io.File

internal class VolumePathResolver(
    val appContext: Context
) {
    fun resolve(file: File): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getVolumePathViaNewApi(file)
        } else {
            getVolumePathFromLegacyApi(file)
        }
    }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun getVolumePathViaNewApi(file: File): String? {
        val storageManager = appContext.getSystemService(StorageManager::class.java)
        val volume = storageManager.getStorageVolume(file)
        return volume?.directory?.absolutePath
    }

    private fun getVolumePathFromLegacyApi(file: File): String? {
        val filesDirs = appContext.getExternalFilesDirs(null)
        val match = filesDirs.firstOrNull { file.absolutePath.contains(it.absolutePath) }
        return match?.absolutePath
    }
}