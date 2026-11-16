package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.StatFs
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileSystemStats
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class FileStatsResolverTest {
    @Test
    fun resolveShouldReturnCapacityAndAvailableSpaceIfPathCanBeRead() {
        Mockito.mockConstruction(StatFs::class.java) { stats, _ ->
            Mockito.`when`(stats.totalBytes).thenReturn(2_000L)
            Mockito.`when`(stats.availableBytes).thenReturn(500L)
        }.use {
            assertEquals(
                FileSystemStats(capacityInBytes = 2_000L, availableSpaceInBytes = 500L),
                FileStatsResolver().resolve("/storage/emulated/0"),
            )
        }
    }

    @Test
    fun resolveShouldReturnNullIfPathCanNotBeRead() {
        Mockito.mockConstruction(StatFs::class.java) { _, _ ->
            throw IllegalArgumentException("Invalid path")
        }.use {
            assertNull(FileStatsResolver().resolve("/storage/1A2B-3C4D"))
        }
    }
}
