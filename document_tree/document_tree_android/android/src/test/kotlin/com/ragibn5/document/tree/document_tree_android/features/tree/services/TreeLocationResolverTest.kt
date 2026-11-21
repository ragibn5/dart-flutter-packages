package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.DocumentsContract
import android.provider.MediaStore
import com.ragibn5.document.tree.document_tree_android.features.tree.models.TreeLocation
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import org.mockito.Mockito
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class TreeLocationResolverTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val context = Mockito.mock(Context::class.java).also {
        Mockito.`when`(it.contentResolver).thenReturn(contentResolver)
    }
    private val primary = volume(isPrimary = true, uuid = null)
    private val sdCard = volume(isPrimary = false, uuid = SD_UUID)
    private val storageManager = Mockito.mock(StorageManager::class.java).also {
        Mockito.`when`(it.storageVolumes).thenReturn(listOf(primary, sdCard))
    }
    private val volumeRoots = Mockito.mock(VolumeRootResolver::class.java)

    private val treeUri = uri(STORAGE_AUTHORITY)
    private val rootUri = uri(STORAGE_AUTHORITY)
    private val childrenUri = uri(STORAGE_AUTHORITY)
    private val mediaUri = uri("media")

    private val documentsContract = Mockito.mockStatic(DocumentsContract::class.java)
    private val mediaStore = Mockito.mockStatic(MediaStore::class.java)

    @TempDir
    lateinit var volumeRoot: File

    @AfterEach
    fun tearDown() {
        documentsContract.close()
        mediaStore.close()
    }

    private fun resolver(sdkInt: Int) = TreeLocationResolver(context, storageManager, volumeRoots, sdkInt)

    private fun givenTreeDocumentId(documentId: String) {
        documentsContract.`when`<String> { DocumentsContract.getTreeDocumentId(treeUri) }.thenReturn(documentId)
        documentsContract.`when`<Uri> { DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId) }
            .thenReturn(rootUri)
        documentsContract.`when`<Uri> { DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId) }
            .thenReturn(childrenUri)
    }

    /** MediaStore knows the tree's folder as [volumeName], [relativePath] and [name]. */
    private fun givenFolderRow(volumeName: String, relativePath: String?, name: String) {
        givenTreeDocumentId(DOCUMENT_ID)
        mediaStore.`when`<Uri> { MediaStore.getMediaUri(context, rootUri) }.thenReturn(mediaUri)
        val cursor = Mockito.mock(Cursor::class.java)
        Mockito.`when`(cursor.moveToFirst()).thenReturn(true)
        Mockito.`when`(cursor.getString(0)).thenReturn(volumeName)
        Mockito.`when`(cursor.getString(1)).thenReturn(relativePath)
        Mockito.`when`(cursor.getString(2)).thenReturn(name)
        Mockito.`when`(contentResolver.query(Mockito.eq(mediaUri), Mockito.any(), Mockito.isNull(), Mockito.isNull(), Mockito.isNull()))
            .thenReturn(cursor)
    }

    private fun givenStoragePermission(isGranted: Boolean) {
        Mockito.`when`(context.checkSelfPermission(Mockito.anyString())).thenReturn(
            if (isGranted) PackageManager.PERMISSION_GRANTED else PackageManager.PERMISSION_DENIED,
        )
    }

    /** The tree lists [names] as its entries. */
    private fun givenTreeEntries(vararg names: String) {
        val cursor = Mockito.mock(Cursor::class.java)
        var index = -1
        Mockito.`when`(cursor.moveToNext()).thenAnswer { ++index < names.size }
        Mockito.`when`(cursor.getString(0)).thenAnswer { names[index] }
        Mockito.`when`(contentResolver.query(Mockito.eq(childrenUri), Mockito.any(), Mockito.isNull(), Mockito.isNull(), Mockito.isNull()))
            .thenReturn(cursor)
    }

    /** The primary volume's root is [volumeRoot], holding [names] in its `Pictures` folder. */
    private fun givenPicturesOnDisk(vararg names: String) {
        Mockito.`when`(volumeRoots.resolve(primary)).thenReturn(volumeRoot.absolutePath)
        val pictures = File(volumeRoot, "Pictures").apply { mkdirs() }
        names.forEach { File(pictures, it).writeText("") }
    }

    @Test
    fun resolveShouldGivePrimaryAndTheFoldersPathOnAndroid10AndLater() {
        givenFolderRow("external_primary", "Android/media/com.whatsapp/WhatsApp/Media/", "WhatsApp Images")

        assertEquals(
            TreeLocation("primary", "Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images"),
            resolver(Q).resolve(treeUri),
        )
    }

    @Test
    fun resolveShouldGiveTheVolumesOwnUuidForMediaStoresLowerCaseName() {
        givenFolderRow("b63b-1e04", "INS/DCIM/", "Camera")

        assertEquals(TreeLocation(SD_UUID, "INS/DCIM/Camera"), resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldGiveTheNameAloneForATopLevelFolder() {
        givenFolderRow("external_primary", "/", "SHAREit")

        assertEquals(TreeLocation("primary", "SHAREit"), resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldGiveTheNameAloneIfTheRowHasNoParentPath() {
        givenFolderRow("external_primary", null, "SHAREit")

        assertEquals(TreeLocation("primary", "SHAREit"), resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullIfMediaStoresVolumeIsntMounted() {
        givenFolderRow("1111-2222", "DCIM/", "Camera")

        assertNull(resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullIfMediaStoreDoesntKnowTheFolder() {
        givenTreeDocumentId(DOCUMENT_ID)
        mediaStore.`when`<Uri> { MediaStore.getMediaUri(context, rootUri) }.thenReturn(null)

        assertNull(resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullIfTheFoldersRowIsGone() {
        givenFolderRow("external_primary", "DCIM/", "Camera")
        val empty = Mockito.mock(Cursor::class.java)
        Mockito.`when`(contentResolver.query(Mockito.eq(mediaUri), Mockito.any(), Mockito.isNull(), Mockito.isNull(), Mockito.isNull()))
            .thenReturn(empty)

        assertNull(resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullIfTheGrantNoLongerCoversTheFolder() {
        givenTreeDocumentId(DOCUMENT_ID)
        mediaStore.`when`<Uri> { MediaStore.getMediaUri(context, rootUri) }
            .thenThrow(SecurityException("No grant"))

        assertNull(resolver(Q).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullForAnotherProvider() {
        assertNull(resolver(Q).resolve(uri("com.google.android.apps.docs.storage")))
    }

    @Test
    fun resolveShouldGiveTheDocumentIdsLocationBeforeAndroid10WithoutTheStoragePermission() {
        givenTreeDocumentId("$SD_UUID:DCIM/Camera")
        givenStoragePermission(isGranted = false)

        assertEquals(TreeLocation(SD_UUID, "DCIM/Camera"), resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid10IfTheDocumentIdsVolumeIsntMounted() {
        givenTreeDocumentId("home:Notes")
        givenStoragePermission(isGranted = false)

        assertNull(resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid10IfTheDocumentIdNamesNoVolume() {
        givenTreeDocumentId("Notes")

        assertNull(resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldGiveTheLocationBeforeAndroid10IfTheFolderOnDiskHoldsTheTreesEntries() {
        givenTreeDocumentId("primary:Pictures")
        givenStoragePermission(isGranted = true)
        givenPicturesOnDisk("a.jpg", "b.jpg")
        givenTreeEntries("b.jpg", "a.jpg")

        assertEquals(TreeLocation("primary", "Pictures"), resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid10IfTheFolderOnDiskHoldsOtherEntries() {
        givenTreeDocumentId("primary:Pictures")
        givenStoragePermission(isGranted = true)
        givenPicturesOnDisk("a.jpg", "b.jpg")
        givenTreeEntries("a.jpg")

        assertNull(resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid10IfTheFolderIsntOnDisk() {
        givenTreeDocumentId("primary:Pictures")
        givenStoragePermission(isGranted = true)
        Mockito.`when`(volumeRoots.resolve(primary)).thenReturn(volumeRoot.absolutePath)
        givenTreeEntries("a.jpg")

        assertNull(resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldBeNullBeforeAndroid10IfTheTreesEntriesCantBeListed() {
        givenTreeDocumentId("primary:Pictures")
        givenStoragePermission(isGranted = true)
        givenPicturesOnDisk("a.jpg")

        assertNull(resolver(P).resolve(treeUri))
    }

    @Test
    fun resolveShouldGiveTheDocumentIdsLocationBeforeAndroid10IfTheVolumesRootIsUnknown() {
        givenTreeDocumentId("primary:Pictures")
        givenStoragePermission(isGranted = true)

        assertEquals(TreeLocation("primary", "Pictures"), resolver(P).resolve(treeUri))
    }

    private fun uri(authority: String): Uri = Mockito.mock(Uri::class.java).also {
        Mockito.`when`(it.authority).thenReturn(authority)
    }

    private fun volume(isPrimary: Boolean, uuid: String?): StorageVolume =
        Mockito.mock(StorageVolume::class.java).also {
            Mockito.`when`(it.isPrimary).thenReturn(isPrimary)
            Mockito.`when`(it.uuid).thenReturn(uuid)
        }

    private companion object {
        const val STORAGE_AUTHORITY = "com.android.externalstorage.documents"
        const val SD_UUID = "B63B-1E04"
        const val DOCUMENT_ID = "primary:Folder"
        const val Q = 29
        const val P = 28
    }
}
