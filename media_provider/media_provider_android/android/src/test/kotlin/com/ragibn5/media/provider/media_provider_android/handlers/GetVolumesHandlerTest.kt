package com.ragibn5.media.provider.media_provider_android.handlers

import android.content.Context
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderService
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceImpl
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
            VolumeInfo(isPrimary = true, uuid = null),
            VolumeInfo(isPrimary = false, uuid = "1234-5678"),
        )

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(call()),
        )
    }

    @Test
    fun `replies with volumes the caller can decode back`() = runTest {
        service.items = listOf(
            VolumeInfo(isPrimary = true, uuid = null),
            VolumeInfo(isPrimary = false, uuid = "1234-5678"),
        )

        val reply = handler.handle(call()) as String

        assertEquals(service.items, Json.decodeFromString<List<VolumeInfo>>(reply))
    }

    @Test
    fun `replies with an empty JSON array when the device has no volumes`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(call()))
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

    private fun volumeOn(isPrimary: Boolean, uuid: String?): StorageVolume =
        Mockito.mock(StorageVolume::class.java).apply {
            Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(this.uuid).thenReturn(uuid)
        }

    private fun serviceOver(vararg volumes: StorageVolume) =
        VolumeProviderServiceImpl(storageManager).apply {
            Mockito.`when`(storageManager.storageVolumes).thenReturn(volumes.toList())
        }

    @Test
    fun `reports each mounted volume in the order the device lists them`() {
        val service = serviceOver(
            volumeOn(isPrimary = true, uuid = null),
            volumeOn(isPrimary = false, uuid = "1234-5678"),
        )

        assertEquals(
            listOf(
                VolumeInfo(isPrimary = true, uuid = null),
                VolumeInfo(isPrimary = false, uuid = "1234-5678"),
            ),
            service.getVolumes(),
        )
    }

    @Test
    fun `reports the primary volume as having no UUID`() {
        val service = serviceOver(volumeOn(isPrimary = true, uuid = null))

        assertEquals(listOf(VolumeInfo(isPrimary = true, uuid = null)), service.getVolumes())
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