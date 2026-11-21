package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.content.Context
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class VolumeRootResolverTest {
    private val context = Mockito.mock(Context::class.java)
    private val storageManager = Mockito.mock(StorageManager::class.java)
    private val primary = volume(isPrimary = true, uuid = null)
    private val sdCard = volume(isPrimary = false, uuid = "B63B-1E04")
    private val environment = Mockito.mockStatic(Environment::class.java)

    private val primaryAppFolder = File("/storage/emulated/0/Android/data/app/files")
    private val sdAppFolder = File("/storage/B63B-1E04/Android/data/app/files")

    @AfterEach
    fun tearDown() {
        environment.close()
    }

    private fun resolver(sdkInt: Int) = VolumeRootResolver(context, storageManager, sdkInt)

    private fun givenAppFolders(vararg folders: File?) {
        Mockito.`when`(context.getExternalFilesDirs(null)).thenReturn(arrayOf(*folders))
        Mockito.`when`(storageManager.getStorageVolume(primaryAppFolder)).thenReturn(primary)
        Mockito.`when`(storageManager.getStorageVolume(sdAppFolder)).thenReturn(sdCard)
    }

    @Test
    fun resolveShouldGiveTheVolumesDirectoryOnAndroid11AndLater() {
        Mockito.`when`(sdCard.directory).thenReturn(File("/storage/B63B-1E04"))

        assertEquals("/storage/B63B-1E04", resolver(R).resolve(sdCard))
    }

    @Test
    fun resolveShouldGiveTheExternalStorageDirectoryForThePrimaryVolumeBeforeAndroid11() {
        environment.`when`<File> { Environment.getExternalStorageDirectory() }
            .thenReturn(File("/storage/emulated/0"))

        assertEquals("/storage/emulated/0", resolver(Q).resolve(primary))
    }

    @Test
    fun resolveShouldFindASecondaryVolumesRootThroughTheAppsFolderOnItBeforeAndroid11() {
        givenAppFolders(primaryAppFolder, null, sdAppFolder)

        assertEquals("/storage/B63B-1E04", resolver(Q).resolve(sdCard))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid11IfNoAppFolderIsOnTheVolume() {
        givenAppFolders(primaryAppFolder)

        assertNull(resolver(Q).resolve(sdCard))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid11ForASecondaryVolumeWithoutUuid() {
        assertNull(resolver(Q).resolve(volume(isPrimary = false, uuid = null)))
    }

    private fun volume(isPrimary: Boolean, uuid: String?): StorageVolume =
        Mockito.mock(StorageVolume::class.java).also {
            Mockito.`when`(it.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(it.uuid).thenReturn(uuid)
        }

    private companion object {
        const val R = 30
        const val Q = 29
    }
}
