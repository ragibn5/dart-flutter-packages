package com.ragibn5.document.tree.document_tree_android.features.document.services

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import com.ragibn5.document.tree.document_tree_android.features.document.models.ContentHash
import com.ragibn5.document.tree.document_tree_android.features.document.models.ContentHashAlgorithm
import com.ragibn5.document.tree.document_tree_android.features.document.models.CopyDocumentRequest
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentFolder
import com.ragibn5.document.tree.document_tree_android.features.document.models.DocumentRow
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class DocumentCopyServiceTest {
    private val treeUri = Mockito.mock(Uri::class.java)
    private val sourceUri = Mockito.mock(Uri::class.java)
    private val copyUri = Mockito.mock(Uri::class.java)
    private val uris = Mockito.mockStatic(Uri::class.java).also {
        it.`when`<Uri> { Uri.parse(TREE_URI) }.thenReturn(treeUri)
        it.`when`<Uri> { Uri.parse(SOURCE_URI) }.thenReturn(sourceUri)
    }
    private val documentsContract = Mockito.mockStatic(DocumentsContract::class.java).also {
        it.`when`<Uri> { DocumentsContract.buildDocumentUriUsingTree(treeUri, COPY_ID) }.thenReturn(copyUri)
    }

    private val folder = DocumentFolder(documentId = FOLDER_ID, path = "DCIM")
    private val copyRow = DocumentRow(
        documentId = COPY_ID,
        displayName = "IMG_1.jpg",
        mimeType = "image/jpeg",
        flags = 0,
        sizeInBytes = CONTENT.size.toLong(),
        lastModifiedInMillis = 1763078400000,
    )
    private val written = ByteArrayOutputStream()

    private val contentResolver = Mockito.mock(ContentResolver::class.java).also {
        Mockito.`when`(it.openInputStream(sourceUri)).thenAnswer { ByteArrayInputStream(CONTENT) }
        Mockito.`when`(it.openOutputStream(copyUri, "w")).thenReturn(written)
    }
    private val rowReader = Mockito.mock(DocumentRowReader::class.java).also {
        Mockito.`when`(it.readChildren(treeUri, FOLDER_ID)).thenReturn(emptyList())
        Mockito.`when`(it.readDocument(treeUri, COPY_ID)).thenReturn(copyRow)
    }
    private val pathResolver = Mockito.mock(DocumentPathResolver::class.java).also {
        Mockito.`when`(it.findFolder(treeUri, "DCIM", null)).thenReturn(folder)
    }
    private val creator = Mockito.mock(DocumentCreator::class.java).also {
        Mockito.`when`(it.create(treeUri, folder, "image/jpeg", "IMG_1.jpg")).thenReturn(copyRow)
    }
    private val mimeTypeResolver = Mockito.mock(DocumentMimeTypeResolver::class.java).also {
        Mockito.`when`(it.resolve(null, "IMG_1.jpg", sourceUri)).thenReturn("image/jpeg")
    }

    @AfterEach
    fun tearDown() {
        uris.close()
        documentsContract.close()
    }

    private fun service(dispatcher: CoroutineDispatcher) = DocumentCopyServiceImpl(
        contentResolver = contentResolver,
        grantVerifier = Mockito.mock(WritableGrantVerifier::class.java),
        rowReader = rowReader,
        pathResolver = pathResolver,
        creator = creator,
        mimeTypeResolver = mimeTypeResolver,
        contentWriter = DocumentContentWriter(contentResolver),
        ioDispatcher = dispatcher,
    )

    private fun request(hashAlgorithm: ContentHashAlgorithm?) = CopyDocumentRequest(
        sourceUri = SOURCE_URI,
        treeUri = TREE_URI,
        path = "DCIM/IMG_1.jpg",
        hashAlgorithm = hashAlgorithm,
    )

    @Test
    fun copyShouldWriteSourceBytesIntoCopy() = runTest {
        service(StandardTestDispatcher(testScheduler)).copy(request(hashAlgorithm = null))

        assertContentEquals(CONTENT, written.toByteArray())
    }

    @Test
    fun copyShouldReturnSha256OfCopiedBytesIfRequestAsksForIt() = runTest {
        val copied = service(StandardTestDispatcher(testScheduler))
            .copy(request(hashAlgorithm = ContentHashAlgorithm.SHA_256))

        assertEquals(ContentHash(ContentHashAlgorithm.SHA_256, CONTENT_SHA_256), copied.contentHash)
    }

    @Test
    fun copyShouldReturnNoHashIfRequestAsksForNone() = runTest {
        val copied = service(StandardTestDispatcher(testScheduler)).copy(request(hashAlgorithm = null))

        assertNull(copied.contentHash)
    }

    @Test
    fun copyShouldReturnCopyAsTreeDescribesIt() = runTest {
        val copied = service(StandardTestDispatcher(testScheduler)).copy(request(hashAlgorithm = null))

        assertEquals(copyRow.toInfo(treeUri, "DCIM/IMG_1.jpg", grantAllowsWriting = true), copied.document)
    }

    private companion object {
        private const val TREE_URI = "content://com.android.externalstorage.documents/tree/B63B-1E04%3ASync"
        private const val SOURCE_URI = "content://media/external/images/media/1"
        private const val FOLDER_ID = "B63B-1E04:Sync/DCIM"
        private const val COPY_ID = "B63B-1E04:Sync/DCIM/IMG_1.jpg"

        private val CONTENT = "hello".toByteArray()

        /** `printf hello | sha256sum` */
        private const val CONTENT_SHA_256 = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
    }
}
