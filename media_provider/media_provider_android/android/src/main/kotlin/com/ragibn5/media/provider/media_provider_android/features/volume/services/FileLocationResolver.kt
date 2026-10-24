package com.ragibn5.media.provider.media_provider_android.features.volume.services

import com.ragibn5.media.provider.media_provider_android.extensions.ensureTrailingSlash
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import java.io.File

internal class FileLocationResolver(
    private val volumeProviderService: VolumeProviderService,
) {
    /**
     * The mounted volumes.
     *
     * See [refreshVolumes] to know how this is obtained and stored.
     */
    @Volatile
    private var cachedVolumes: List<CachedVolume>? = null

    fun resolve(path: String): FileLocation? {
        val volume = findVolume(path) ?: return null
        val file = File(path)
        val fileParentPath = file.parentFile?.absolutePath?.ensureTrailingSlash() ?: return null
        if (!fileParentPath.startsWith(volume.root)) {
            return null
        }
        return FileLocation(
            volumeIdentity = volume.identity,
            relativeParentPath = fileParentPath.substring(volume.root.length),
            fileNameWithExtension = file.name
        )
    }

    private fun findVolume(path: String): CachedVolume? {
        cachedVolumes?.matching(path)?.let { return it }

        // Not looked up yet, or on a volume mounted since.
        // Look them up again, once. A path that still matches no volume isn't on one.
        return refreshVolumes().matching(path)
    }

    /**
     * Refresh the volume cache.
     *
     * Note: The returned list (and also the cache, after refreshing) is in the descending
     * order of the volume's root path length. This makes sure that when matching a volume,
     * one nested under another wins.
     *
     * @return the new volume cache (for convenience).
     */
    private fun refreshVolumes(): List<CachedVolume> =
        volumeProviderService.getVolumes()
            .map { CachedVolume(it.identity.volumePath.ensureTrailingSlash(), it.identity) }
            .sortedByDescending { it.root.length }
            .also { cachedVolumes = it }

    private fun List<CachedVolume>.matching(path: String): CachedVolume? =
        firstOrNull { path.startsWith(it.root) }

    private class CachedVolume(val root: String, val identity: VolumeIdentity)
}
