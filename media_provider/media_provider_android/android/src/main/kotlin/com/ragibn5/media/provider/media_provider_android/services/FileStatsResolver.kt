package com.ragibn5.media.provider.media_provider_android.services

import android.os.StatFs
import com.ragibn5.media.provider.media_provider_android.models.FileSystemStats

internal class FileStatsResolver {
    /**
     * Resolve the filesystem stats for a given path.
     *
     * Returns null if the stats can not be obtained for any reason.
     * */
    fun resolve(path: String): FileSystemStats? {
        val stats = runCatching { StatFs(path) }.getOrNull()
            ?: return null
        return FileSystemStats(
            capacityInBytes = stats.totalBytes,
            availableSpaceInBytes = stats.availableBytes,
        )
    }
}