package com.ragibn5.media.provider.media_provider_android.services

import android.os.StatFs
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileSystemStats
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileStatsResolver
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [FileStatsResolver] reads how much space a filesystem holds.
 *
 * `StatFs` is a framework stub under unit tests, so it is intercepted at
 * construction: that is the only way to hand back a filesystem size without a
 * device behind it. The size a stub reports is therefore the test's, and the
 * point of these tests is which [StatFs] property each figure is read from, and
 * that a filesystem which cannot be read yields no figures at all.
 *
 * A path that cannot be resolved to a volume at all is not this resolver's
 * business; it is reported as no stats, and the caller reports the volume with
 * zero size.
 */
internal class FileStatsResolverTest {
    private val resolver = FileStatsResolver()

    private fun statFsReporting(totalBytes: Long, availableBytes: Long): AutoCloseable {
        return Mockito.mockConstruction(StatFs::class.java) { stats, _ ->
            Mockito.`when`(stats.totalBytes).thenReturn(totalBytes)
            Mockito.`when`(stats.availableBytes).thenReturn(availableBytes)
        }
    }

    private fun statFsThrowing(): AutoCloseable {
        return Mockito.mockConstruction(StatFs::class.java) { _, _ ->
            throw IllegalArgumentException("path does not exist")
        }
    }

    @Test
    fun `reports the filesystem total as capacity`() {
        statFsReporting(totalBytes = 128_000_000_000L, availableBytes = 64_000_000_000L).use {
            val stats = resolver.resolve("/storage/emulated/0")

            assertEquals(128_000_000_000L, stats?.capacityInBytes)
        }
    }

    @Test
    fun `reports the filesystem free space as available`() {
        // Deliberately different from the capacity: reading the wrong `StatFs`
        // property would otherwise still produce a plausible number.
        statFsReporting(totalBytes = 128_000_000_000L, availableBytes = 64_000_000_000L).use {
            val stats = resolver.resolve("/storage/emulated/0")

            assertEquals(64_000_000_000L, stats?.availableSpaceInBytes)
        }
    }

    @Test
    fun `reports both figures from one read of the filesystem`() {
        statFsReporting(totalBytes = 4096L, availableBytes = 1024L).use {
            assertEquals(
                FileSystemStats(capacityInBytes = 4096L, availableSpaceInBytes = 1024L),
                resolver.resolve("/storage/emulated/0"),
            )
        }
    }

    @Test
    fun `reports no size for a path that names no directory`() {
        // A volume whose card was pulled can still name a path that has since
        // gone away; reading it throws rather than yielding no figures.
        statFsThrowing().use {
            assertNull(resolver.resolve("/storage/1234-5678"))
        }
    }
}