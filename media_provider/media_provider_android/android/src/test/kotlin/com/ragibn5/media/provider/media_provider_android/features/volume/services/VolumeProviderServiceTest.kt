package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileSystemStats
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeState
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class VolumeProviderServiceTest {
    private val storageManager = Mockito.mock(StorageManager::class.java)
    private val volumePathResolver = Mockito.mock(VolumePathResolver::class.java)
    private val volumeTypeResolver = Mockito.mock(VolumeTypeResolver::class.java)
    private val fileStatsResolver = Mockito.mock(FileStatsResolver::class.java)
    private val documentsRootUriResolver = Mockito.mock(DocumentsRootUriResolver::class.java)

    private val service = VolumeProviderServiceImpl(
        storageManager,
        volumePathResolver,
        volumeTypeResolver,
        fileStatsResolver,
        documentsRootUriResolver,
    )

    private val sdCard = Mockito.mock(StorageVolume::class.java).also {
        Mockito.`when`(it.uuid).thenReturn("1A2B-3C4D")
        Mockito.`when`(it.state).thenReturn(Environment.MEDIA_MOUNTED)
        Mockito.`when`(it.isRemovable).thenReturn(true)
        Mockito.`when`(volumeTypeResolver.resolve(it)).thenReturn(VolumeType.SD_CARD)
        Mockito.`when`(documentsRootUriResolver.resolve(it)).thenReturn(SD_CARD_ROOT_URI)
    }

    private fun givenVolumes(vararg volumes: StorageVolume) {
        Mockito.`when`(storageManager.storageVolumes).thenReturn(volumes.toList())
    }

    @Test
    fun getVolumesShouldReportVolumeWithIdentityStateAndSpace() {
        givenVolumes(sdCard)
        Mockito.`when`(volumePathResolver.resolve(sdCard)).thenReturn("/storage/1A2B-3C4D")
        Mockito.`when`(fileStatsResolver.resolve("/storage/1A2B-3C4D"))
            .thenReturn(FileSystemStats(capacityInBytes = 2_000L, availableSpaceInBytes = 500L))

        assertEquals(
            listOf(
                VolumeInfo(
                    identity = VolumeIdentity(
                        uuid = "1A2B-3C4D",
                        type = VolumeType.SD_CARD,
                        volumePath = "/storage/1A2B-3C4D",
                        capacityInBytes = 2_000L,
                        isPrimary = false,
                        isRemovable = true,
                        isEmulated = false,
                    ),
                    state = VolumeState.MOUNTED,
                    availableSpaceInBytes = 500L,
                    documentsRootUri = SD_CARD_ROOT_URI,
                ),
            ),
            service.getVolumes(),
        )
    }

    @Test
    fun getVolumesShouldSkipVolumeIfPathCanNotBeResolved() {
        givenVolumes(sdCard)

        assertEquals(emptyList(), service.getVolumes())
    }

    @Test
    fun getVolumesShouldReportNullSizesIfStatsCanNotBeRead() {
        givenVolumes(sdCard)
        Mockito.`when`(volumePathResolver.resolve(sdCard)).thenReturn("/storage/1A2B-3C4D")

        val volume = service.getVolumes().single()

        assertNull(volume.identity.capacityInBytes)
        assertNull(volume.availableSpaceInBytes)
    }

    @Test
    fun getVolumesShouldReportPathWithoutTrailingSlash() {
        givenVolumes(sdCard)
        Mockito.`when`(volumePathResolver.resolve(sdCard)).thenReturn("/storage/1A2B-3C4D/")

        assertEquals("/storage/1A2B-3C4D", service.getVolumes().single().identity.volumePath)
    }

    private companion object {
        const val SD_CARD_ROOT_URI = "content://com.android.externalstorage.documents/root/1A2B-3C4D"
    }
}
