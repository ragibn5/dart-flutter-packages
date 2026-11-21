package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import java.io.File

/**
 * Resolves a volume's root folder on the filesystem, such as `/storage/B63B-1E04`.
 *
 * Note: The same approach as media_provider_android's `VolumePathResolver`.
 */
internal class VolumeRootResolver(
    private val context: Context,
    private val storageManager: StorageManager,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    /** The root folder of [volume], or `null` if it can't be found, such as when unmounted. */
    fun resolve(volume: StorageVolume): String? {
        if (sdkInt >= Build.VERSION_CODES.R) {
            @SuppressLint("NewApi")
            return volume.directory?.absolutePath
        }
        if (volume.isPrimary) {
            @Suppress("DEPRECATION")
            return Environment.getExternalStorageDirectory().absolutePath
        }

        // Before Android 11, a secondary volume's root is found through the app's own folder
        // on it, `<root>/Android/data/<package>/files`.
        val uuid = volume.uuid ?: return null
        for (dir in context.getExternalFilesDirs(null).filterNotNull()) {
            if (storageManager.getStorageVolume(dir)?.uuid == uuid) {
                return dir.absolutePath.substringBefore("${File.separator}Android${File.separator}data")
            }
        }
        return null
    }
}
