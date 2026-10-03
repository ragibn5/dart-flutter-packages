package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.os.Build
import android.os.storage.StorageManager
import androidx.annotation.RequiresApi
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import java.io.File

internal class VolumePathResolver(
    private val appContext: Context,
    private val storageManager: StorageManager,
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
        val volume = storageManager.getStorageVolume(file)
        return volume?.directory?.absolutePath
    }

    private fun getVolumePathFromLegacyApi(file: File): String? {
        val volumePaths = appContext.getExternalFilesDirs(null)
            .map { it.absolutePath.trimToVolumeRoot(true).ensureTrailingSlash() }
        val match = volumePaths.firstOrNull {
            file.getFSEAwarePath().contains(it)
        }

        return match?.ensureNoTrailingSlash()
    }

    private fun File.getFSEAwarePath(): String {
        return if (isDirectory) absolutePath.ensureTrailingSlash()
        else absolutePath.ensureNoTrailingSlash()
    }

    private fun String.trimToVolumeRoot(absolute: Boolean): String {
        val prefix = if (absolute) File.separator else ""
        return prefix + this.split(File.separator)
            .filter { it.isNotEmpty() }
            .dropLast(4)
            .joinToString(File.separator)
    }
}