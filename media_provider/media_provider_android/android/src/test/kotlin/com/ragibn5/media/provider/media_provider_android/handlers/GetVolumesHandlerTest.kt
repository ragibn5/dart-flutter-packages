package com.ragibn5.media.provider.media_provider_android.handlers

import android.content.Context
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.os.Environment
import com.ragibn5.media.provider.media_provider_android.models.VolumeIdentity
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.models.VolumeState
import com.ragibn5.media.provider.media_provider_android.models.VolumeType
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderService
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceImpl
import com.ragibn5.media.provider.media_provider_android.services.VolumeTypeResolver
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals

internal class GetVolumesHandlerTest {
    private val service = FakeVolumeProviderService()
    private val handler = GetVolumesHandler(service)

    private fun call() = MethodCall("getVolumes", null)

    @Test
    fun `serves the method the Dart side calls`() {
        assertEquals("getVolumes", handler.method)
    }

    @Test
    fun `replies with the service's volumes encoded as JSON`() = runTest {
        service.items = listOf(
            primaryVolume(),
            secondaryVolume(),
        )

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(call()),
        )
    }

    @Test
    fun `replies with volumes the caller can decode back`() = runTest {
        service.items = listOf(
            primaryVolume(),
            secondaryVolume(),
        )

        val reply = handler.handle(call()) as String

        assertEquals(service.items, Json.decodeFromString<List<VolumeInfo>>(reply))
    }

    @Test
    fun `replies with an empty JSON array when the device has no volumes`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(call()))
    }

    private companion object {
        fun primaryVolume() = VolumeInfo(
            state = VolumeState.MOUNTED,
            identity = VolumeIdentity(
                isPrimary = true,
                isRemovable = false,
                isEmulated = true,
                uuid = null,
                type = VolumeType.PRIMARY,
            ),
        )

        fun secondaryVolume() = VolumeInfo(
            state = VolumeState.MOUNTED_READ_ONLY,
            identity = VolumeIdentity(
                isPrimary = false,
                isRemovable = true,
                isEmulated = false,
                uuid = "1234-5678",
                type = VolumeType.SD_CARD,
            ),
        )
    }

    private class FakeVolumeProviderService : VolumeProviderService {
        var items: List<VolumeInfo> = emptyList()

        override fun getVolumes(): List<VolumeInfo> = items
    }
}

/**
 * [com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceImpl] reports the
 * device's storage volumes, which is what a `QuerySpec` is later matched against.
 *
 * `StorageManager` is mocked so the volumes and their order are the test's, not a
 * device's.
 */
internal class VolumeProviderServiceImplTest {
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)

    private fun volumeOn(
        isPrimary: Boolean,
        uuid: String?,
        isRemovable: Boolean = false,
        isEmulated: Boolean = false,
        state: String? = Environment.MEDIA_MOUNTED,
    ): StorageVolume =
        Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(this.uuid).thenReturn(uuid)
            Mockito.`when`(this.isRemovable).thenReturn(isRemovable)
            Mockito.`when`(this.isEmulated).thenReturn(isEmulated)
            Mockito.`when`(this.state).thenReturn(state)
        }

    private fun serviceOver(vararg volumes: StorageVolume) =
        VolumeProviderServiceImpl(storageManager, VolumeTypeResolver()).apply {
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
                    identity = identity(true, null, isEmulated = true, type = VolumeType.PRIMARY),
                ),
                VolumeInfo(
                    state = VolumeState.MOUNTED,
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
    fun `asks the context for a storage manager`() {
        val context = Mockito.mock(Context::class.java)
        Mockito.`when`(context.getSystemService(StorageManager::class.java))
            .thenReturn(storageManager)

        val service = VolumeProviderServiceFactory.create(context)

        Mockito.verify(context).getSystemService(StorageManager::class.java)
        assertEquals(emptyList(), service.getVolumes())
    }
}