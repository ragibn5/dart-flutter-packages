package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.testing.anyOf
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class VolumePathResolverTest {
    private val context = Mockito.mock(Context::class.java)
    private val storageManager = Mockito.mock(StorageManager::class.java)

    private fun resolver(sdkInt: Int) = VolumePathResolver(context, storageManager, sdkInt)

    private fun volume(uuid: String? = null, isPrimary: Boolean = false, directory: String? = null) =
        Mockito.mock(StorageVolume::class.java).also {
            Mockito.`when`(it.uuid).thenReturn(uuid)
            Mockito.`when`(it.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(it.directory).thenReturn(directory?.let(::File))
        }

    /** Makes the app's external files dirs sit on [owner], below API 30. */
    private fun givenFilesDirsOn(owner: StorageVolume?, vararg dirs: String) {
        Mockito.`when`(context.getExternalFilesDirs(null)).thenReturn(dirs.map(::File).toTypedArray())
        Mockito.`when`(storageManager.getStorageVolume(anyOf(File::class.java))).thenReturn(owner)
    }

    @Test
    fun resolveShouldReturnVolumeDirectoryIfApiIs30OrAbove() {
        val volume = volume(directory = "/storage/1A2B-3C4D")

        assertEquals("/storage/1A2B-3C4D", resolver(Build.VERSION_CODES.R).resolve(volume))
    }

    @Test
    fun resolveShouldReturnNullIfApiIs30OrAboveAndVolumeHasNoDirectory() {
        assertNull(resolver(Build.VERSION_CODES.R).resolve(volume()))
    }

    @Test
    fun resolveShouldReturnExternalStorageDirectoryIfApiIsBelow30AndVolumeIsPrimary() {
        Mockito.mockStatic(Environment::class.java).use { environment ->
            environment.`when`<File> { Environment.getExternalStorageDirectory() }
                .thenReturn(File("/storage/emulated/0"))

            assertEquals(
                "/storage/emulated/0",
                resolver(Build.VERSION_CODES.Q).resolve(volume(isPrimary = true)),
            )
        }
    }

    @Test
    fun resolveShouldReturnNullIfApiIsBelow30AndVolumeHasNoUuid() {
        assertNull(resolver(Build.VERSION_CODES.Q).resolve(volume()))
    }

    @Test
    fun resolveShouldReturnRootOfMatchingFilesDirIfApiIsBelow30() {
        val volume = volume(uuid = "1A2B-3C4D")
        givenFilesDirsOn(volume, "/storage/1A2B-3C4D/Android/data/org.example/files")

        assertEquals("/storage/1A2B-3C4D", resolver(Build.VERSION_CODES.Q).resolve(volume))
    }

    @Test
    fun resolveShouldReturnNullIfApiIsBelow30AndNoFilesDirIsOnVolume() {
        val volume = volume(uuid = "1A2B-3C4D")
        givenFilesDirsOn(volume(uuid = "5E6F-7A8B"), "/storage/5E6F-7A8B/Android/data/org.example/files")

        assertNull(resolver(Build.VERSION_CODES.Q).resolve(volume))
    }

    @Test
    fun resolveShouldReturnWholeFilesDirIfApiIsBelow30AndDirHasNoSandboxMarker() {
        val volume = volume(uuid = "1A2B-3C4D")
        givenFilesDirsOn(volume, "/mnt/1A2B-3C4D")

        assertEquals("/mnt/1A2B-3C4D", resolver(Build.VERSION_CODES.Q).resolve(volume))
    }
}
