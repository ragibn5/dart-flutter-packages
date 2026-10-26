package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.features.volume.di.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeState
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals

/**
 * [VolumeProviderServiceImpl] reports the
 * device's storage volumes, which is what a `QuerySpec` is later matched against.
 *
 * `StorageManager` is mocked so the volumes and their order are the test's, not a
 * device's.
 */
internal class VolumeProviderServiceImplTest {
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)

    /**
     * @param path where the volume is mounted. A volume reports no root at all
     *   when this is `null`, which is how an unmounted volume looks.
     */
    private fun volumeOn(
        isPrimary: Boolean,
        uuid: String?,
        isRemovable: Boolean = false,
        isEmulated: Boolean = false,
        state: String? = Environment.MEDIA_MOUNTED,
        path: String? = null,
    ): StorageVolume =
        Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(this.uuid).thenReturn(uuid)
            Mockito.`when`(this.isRemovable).thenReturn(isRemovable)
            Mockito.`when`(this.isEmulated).thenReturn(isEmulated)
            Mockito.`when`(this.state).thenReturn(state)
            Mockito.`when`(this.directory).thenReturn(path?.let(::File))
        }

    private fun serviceOver(vararg volumes: StorageVolume) =
        VolumeProviderServiceImpl(
            storageManager,
            VolumePathResolver(
                Mockito.mock(Context::class.java),
                storageManager,
                // Pinned because a mock reports no API level, and the branch the
                // resolver takes is what VolumePathResolverTest covers.
                Build.VERSION_CODES.R,
            ),
            VolumeTypeResolver(),
        ).apply {
            Mockito.`when`(storageManager.storageVolumes).thenReturn(volumes.toList())
        }

    private fun identity(
        isPrimary: Boolean,
        uuid: String?,
        isRemovable: Boolean = false,
        isEmulated: Boolean = false,
        type: VolumeType,
    ) = VolumeIdentity(
        isPrimary = isPrimary,
        isRemovable = isRemovable,
        isEmulated = isEmulated,
        uuid = uuid,
        capacityInBytes = 0,
        type = type,
    )

    @Test
    fun `reports each mounted volume in the order the device lists them`() {
        val service = serviceOver(
            volumeOn(isPrimary = true, uuid = null, isEmulated = true),
            volumeOn(isPrimary = false, uuid = "1234-5678", isRemovable = true),
        )

        assertEquals(
            listOf(
                VolumeInfo(
                    state = VolumeState.MOUNTED,
                    availableSpaceInBytes = 0,
                    identity = identity(true, null, isEmulated = true, type = VolumeType.PRIMARY),
                ),
                VolumeInfo(
                    state = VolumeState.MOUNTED,
                    availableSpaceInBytes = 0,
                    identity = identity(
                        false,
                        "1234-5678",
                        isRemovable = true,
                        // No block device id is readable on a mock, so the type
                        // stays unresolved.
                        type = VolumeType.UNKNOWN_REMOVABLE,
                    ),
                ),
            ),
            service.getVolumes(),
        )
    }

    @Test
    fun `reports the primary volume as having no UUID`() {
        val service = serviceOver(volumeOn(isPrimary = true, uuid = null))

        assertEquals(
            listOf(
                VolumeInfo(
                    state = VolumeState.MOUNTED,
                    availableSpaceInBytes = 0,
                    identity = identity(true, null, type = VolumeType.PRIMARY),
                ),
            ),
            service.getVolumes(),
        )
    }

    @Test
    fun `reports a non-primary non-removable volume as unknown`() {
        val service = serviceOver(volumeOn(isPrimary = false, uuid = "1234-5678"))

        assertEquals(
            listOf(
                VolumeInfo(
                    state = VolumeState.MOUNTED,
                    availableSpaceInBytes = 0,
                    identity = identity(false, "1234-5678", type = VolumeType.UNKNOWN),
                ),
            ),
            service.getVolumes(),
        )
    }

    @Test
    fun `maps the volume's state onto the report`() {
        val service = serviceOver(
            volumeOn(isPrimary = true, uuid = null, state = Environment.MEDIA_EJECTING),
            volumeOn(
                isPrimary = false,
                uuid = "1234-5678",
                isRemovable = true,
                state = Environment.MEDIA_UNMOUNTED,
            ),
        )

        assertEquals(
            listOf(VolumeState.EJECTING, VolumeState.UNMOUNTED),
            service.getVolumes().map { it.state },
        )
    }

    @Test
    fun `reports an unrecognized volume state as unknown`() {
        val service = serviceOver(volumeOn(isPrimary = true, uuid = null, state = "something-else"))

        assertEquals(listOf(VolumeState.UNKNOWN), service.getVolumes().map { it.state })
    }

    @Test
    fun `reports a volume reporting no state as unknown`() {
        val service = serviceOver(volumeOn(isPrimary = true, uuid = null, state = null))

        assertEquals(listOf(VolumeState.UNKNOWN), service.getVolumes().map { it.state })
    }

    @Test
    fun `reports nothing on a device with no volumes`() {
        assertEquals(emptyList(), serviceOver().getVolumes())
    }

    @Test
    fun `reports the filesystem's total as capacity and its free space as available`() {
        // The two are deliberately different values: reading the wrong `StatFs`
        // property would otherwise still produce a plausible number.
        Mockito.mockConstruction(StatFs::class.java) { stats, _ ->
            Mockito.`when`(stats.totalBytes).thenReturn(128_000_000_000L)
            Mockito.`when`(stats.availableBytes).thenReturn(64_000_000_000L)
        }.use {
            val volume = serviceOver(
                volumeOn(
                    isPrimary = true,
                    uuid = null,
                    isEmulated = true,
                    path = "/storage/emulated/0",
                ),
            ).getVolumes().single()

            assertEquals(128_000_000_000L, volume.identity.capacityInBytes)
            assertEquals(64_000_000_000L, volume.availableSpaceInBytes)
        }
    }

    @Test
    fun `reports a volume with no root as having no capacity or free space`() {
        // No directory is stubbed, so the volume resolves to no path at all.
        val volume = serviceOver(
            volumeOn(isPrimary = true, uuid = null, isEmulated = true),
        ).getVolumes().single()

        assertEquals(0L, volume.identity.capacityInBytes)
        assertEquals(0L, volume.availableSpaceInBytes)
    }

    @Test
    fun `reports a volume whose filesystem cannot be read as having no capacity`() {
        // A path that resolves but whose filesystem is gone is what an ejected
        // card looks like; reading it throws rather than returning no root.
        Mockito.mockConstruction(StatFs::class.java) { _, _ ->
            throw IllegalArgumentException("path does not exist")
        }.use {
            val volume = serviceOver(
                volumeOn(
                    isPrimary = false,
                    uuid = "1234-5678",
                    isRemovable = true,
                    path = "/storage/1234-5678",
                ),
            ).getVolumes().single()

            assertEquals(0L, volume.identity.capacityInBytes)
            assertEquals(0L, volume.availableSpaceInBytes)
        }
    }

    @Test
    fun `reports every volume even when one of them cannot be read`() {
        // The unreadable volume must not take the readable ones down with it.
        Mockito.mockConstruction(StatFs::class.java) { stats, context ->
            val path = context.arguments().firstOrNull() as? String
            if (path == "/storage/1234-5678") {
                throw IllegalArgumentException("path does not exist")
            }
            Mockito.`when`(stats.totalBytes).thenReturn(4096L)
            Mockito.`when`(stats.availableBytes).thenReturn(1024L)
        }.use {
            val volumes = serviceOver(
                volumeOn(
                    isPrimary = true,
                    uuid = null,
                    isEmulated = true,
                    path = "/storage/emulated/0",
                ),
                volumeOn(
                    isPrimary = false,
                    uuid = "1234-5678",
                    isRemovable = true,
                    path = "/storage/1234-5678",
                ),
            ).getVolumes()

            assertEquals(listOf(4096L, 0L), volumes.map { it.identity.capacityInBytes })
            assertEquals(listOf(1024L, 0L), volumes.map { it.availableSpaceInBytes })
        }
    }

    @Test
    fun `asks the context for a storage manager`() {
        val context = Mockito.mock(Context::class.java)
        Mockito.`when`(context.getSystemService(StorageManager::class.java))
            .thenReturn(storageManager)

        val service = VolumeProviderServiceFactory.create(context)

        Mockito.verify(context).getSystemService(StorageManager::class.java)
        assertEquals(emptyList(), service.getVolumes())
    }
}
