package com.ragibn5.media.provider.media_provider_android.features.volume.services

import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.testing.mountedVolume
import com.ragibn5.media.provider.media_provider_android.testing.primaryVolumeIdentity
import com.ragibn5.media.provider.media_provider_android.testing.sdCardVolumeIdentity
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class FileLocationResolverTest {
    /** A [VolumeProviderService] reporting [reported], counting the lookups. */
    private class FakeVolumeProvider(var reported: List<VolumeInfo>) : VolumeProviderService {
        var lookupCount = 0
            private set

        override fun getVolumes(): List<VolumeInfo> {
            lookupCount++
            return reported
        }
    }

    private val provider = FakeVolumeProvider(listOf(mountedVolume(primaryVolumeIdentity)))
    private val resolver = FileLocationResolver(provider)

    @Test
    fun resolveShouldReturnLocationRelativeToVolumeIfPathIsOnVolume() {
        assertEquals(
            FileLocation(primaryVolumeIdentity, "DCIM/Camera/", "IMG_0001.jpg"),
            resolver.resolve("/storage/emulated/0/DCIM/Camera/IMG_0001.jpg"),
        )
    }

    @Test
    fun resolveShouldReturnNullIfPathIsOnNoVolume() {
        assertNull(resolver.resolve("/data/local/tmp/IMG_0001.jpg"))
    }

    @Test
    fun resolveShouldPickNestedVolumeIfVolumesOverlap() {
        val nested = primaryVolumeIdentity.copy(volumePath = "/storage/emulated/0/nested")
        provider.reported = listOf(mountedVolume(primaryVolumeIdentity), mountedVolume(nested))

        assertEquals(
            FileLocation(nested, "DCIM/", "IMG_0001.jpg"),
            resolver.resolve("/storage/emulated/0/nested/DCIM/IMG_0001.jpg"),
        )
    }

    @Test
    fun resolveShouldReuseVolumesIfPathIsOnKnownVolume() {
        resolver.resolve("/storage/emulated/0/DCIM/IMG_0001.jpg")
        resolver.resolve("/storage/emulated/0/DCIM/IMG_0002.jpg")

        assertEquals(1, provider.lookupCount)
    }

    @Test
    fun resolveShouldLookUpVolumesAgainIfPathIsOnNoKnownVolume() {
        resolver.resolve("/storage/emulated/0/DCIM/IMG_0001.jpg")
        provider.reported = listOf(mountedVolume(primaryVolumeIdentity), mountedVolume(sdCardVolumeIdentity))

        assertEquals(
            FileLocation(sdCardVolumeIdentity, "DCIM/", "IMG_0002.jpg"),
            resolver.resolve("/storage/1A2B-3C4D/DCIM/IMG_0002.jpg"),
        )
    }
}
