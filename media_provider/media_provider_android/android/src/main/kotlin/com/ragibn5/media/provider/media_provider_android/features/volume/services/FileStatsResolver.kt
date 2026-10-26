package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.StatFs
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileSystemStats

internal class FileStatsResolver {
    fun resolve(path: String): FileSystemStats? {
        val stats = runCatching { StatFs(path) }.getOrNull()
            ?: return null
        return FileSystemStats(
            capacityInBytes = stats.totalBytes,
            availableSpaceInBytes = stats.availableBytes,
        )
    }
}