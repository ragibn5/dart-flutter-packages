package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeFileLocationResolver
import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollectionRegistry
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertIs
import kotlin.test.assertTrue

/**
 * [MediaStoreServiceImpl] maps requested media types onto collection queries and
 * turns the rows that come back into [com.ragibn5.media.provider.media_provider_android.models.MediaItem]s.
 *
 * The `ContentResolver` is mocked and the SDK level is injected, so these tests
 * describe the service's own querying and row-mapping rules, not the device's.
 */
@OptIn(ExperimentalCoroutinesApi::class)
internal class MediaStoreServiceImplTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val photo = FakeCollection(MediaType.PHOTO)
    private val video = FakeCollection(MediaType.VIDEO)

    private val registry = MediaStoreCollectionRegistry(setOf(photo, video))

    private fun service(sdkInt: Int = Build.VERSION_CODES.R) = MediaStoreServiceImpl(
        contentResolver = contentResolver,
        collectionRegistry = registry,
        // The `uriBuilder` is injected so no test depends on real `ContentUris`
        // behavior, and the reader is pinned to the same API level as the query.
        mediaColumnsReaderFactory = MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = FakeUriBuilder(),
            sdkInt = sdkInt,
        ),
        dispatcher = UnconfinedTestDispatcher(),
        sdkInt = sdkInt,
    )

    private fun returns(vararg cursors: Cursor?) {
        val queue = ArrayDeque(cursors.toList())
        Mockito.`when`(
            contentResolver.query(
                Mockito.any(),
                Mockito.any(),
                Mockito.any(),
                Mockito.any(),
                Mockito.any(),
            ),
        ).thenAnswer { if (queue.isEmpty()) null else queue.removeFirst() }
    }

    private fun queriedUris(): List<Uri> {
        val captor = ArgumentCaptor.forClass(Uri::class.java)
        Mockito.verify(contentResolver, Mockito.atLeastOnce()).query(
            captor.capture(),
            Mockito.any(),
            Mockito.any(),
            Mockito.any(),
            Mockito.any(),
        )
        return captor.allValues
    }

    private fun noQuery() = Mockito.verify(contentResolver, Mockito.never()).query(
        Mockito.any(),
        Mockito.any(),
        Mockito.any(),
        Mockito.any(),
        Mockito.any(),
    )

    @Test
    fun `returns an empty list without querying when no types are requested`() = runTest {
        assertEquals(emptyList(), service().getMedia(emptySet()))
        noQuery()
    }

    @Test
    fun `queries the collection of each requested type`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor, FakeCursor.over(emptyMap()).cursor)

        service().getMedia(setOf(MediaType.PHOTO, MediaType.VIDEO))

        assertEquals(listOf(photo.uri, video.uri), queriedUris())
    }

    @Test
    fun `queries only the requested collection`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor)

        service().getMedia(setOf(MediaType.VIDEO))

        assertEquals(listOf(video.uri), queriedUris())
    }

    @Test
    fun `requests the projection for the given API level`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor)

        service(sdkInt = Build.VERSION_CODES.P).getMedia(setOf(MediaType.PHOTO))

        val projection = ArgumentCaptor.forClass(Array<String>::class.java)
        Mockito.verify(contentResolver).query(
            Mockito.any(),
            projection.capture(),
            Mockito.any(),
            Mockito.any(),
            Mockito.any(),
        )
        // Arrays compare by identity, so compare their contents.
        assertEquals(
            MediaColumnsReader.projectionFor(Build.VERSION_CODES.P),
            projection.value.toList(),
        )
    }

    @Test
    fun `maps each row of the cursor onto a media item`() = runTest {
        val cursor = FakeCursor.over(
            mapOf(BaseColumns._ID to 7L, MediaColumns.DISPLAY_NAME to "cat.jpg"),
        )
        returns(cursor.cursor)

        val items = service().getMedia(setOf(MediaType.PHOTO))

        assertEquals(1, items.size)
        assertEquals("7", items.single().id)
        assertEquals(MediaType.PHOTO, items.single().type)
    }

    @Test
    fun `closes the cursor after reading it`() = runTest {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        returns(cursor.cursor)

        service().getMedia(setOf(MediaType.PHOTO))

        assertTrue(cursor.isClosed, "the cursor must be closed")
    }

    @Test
    fun `closes the cursor even when reading a row fails`() = runTest {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        Mockito.`when`(cursor.cursor.getLong(Mockito.anyInt()))
            .thenThrow(IllegalStateException("boom"))
        returns(cursor.cursor)

        assertFailsWith<IllegalStateException> { service().getMedia(setOf(MediaType.PHOTO)) }

        assertTrue(cursor.isClosed, "the cursor must be closed even on failure")
    }

    @Test
    fun `returns an empty list when the query yields no cursor`() = runTest {
        returns(null)

        assertEquals(emptyList(), service().getMedia(setOf(MediaType.PHOTO)))
    }

    @Test
    fun `returns an empty list when the cursor has no rows`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor)

        assertEquals(emptyList(), service().getMedia(setOf(MediaType.PHOTO)))
    }

    @Test
    fun `fails for a type that has no registered collection`() = runTest {
        val partial = MediaStoreServiceImpl(
            contentResolver = contentResolver,
            collectionRegistry = MediaStoreCollectionRegistry(setOf(photo)),
            mediaColumnsReaderFactory = MediaColumnsReaderFactory(
                fileLocationResolver = fakeFileLocationResolver(),
                uriBuilder = FakeUriBuilder(),
                sdkInt = Build.VERSION_CODES.R,
            ),
            dispatcher = UnconfinedTestDispatcher(),
            sdkInt = Build.VERSION_CODES.R,
        )

        assertFailsWith<NoSuchElementException> { partial.getMedia(setOf(MediaType.VIDEO)) }
        noQuery()
    }

    /**
     * [MediaStoreServiceFactory] is the one place the plugin's object graph is
     * assembled, so these tests assert the wiring is usable: the context's
     * `ContentResolver` is the one queried, its `StorageManager` is the one the
     * volume resolvers get, and whichever collections are passed are the ones
     * served.
     *
     * The collections are injected because `MediaStore`'s own URIs only resolve
     * on a device, and the cursors hold no rows so no item URI is ever built and
     * `MediaUriBuilder.DEFAULT` is never reached.
     */
    private fun contextOver(storageManager: StorageManager): Context {
        val context = Mockito.mock(Context::class.java)
        Mockito.`when`(context.getSystemService(StorageManager::class.java))
            .thenReturn(storageManager)
        Mockito.`when`(context.contentResolver).thenReturn(contentResolver)
        return context
    }

    @Test
    fun `factory serves the context over a queryable service`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor)
        val context = contextOver(Mockito.mock(StorageManager::class.java))

        val service = MediaStoreServiceFactory.create(context, setOf(photo))

        assertIs<MediaStoreServiceImpl>(service)
        assertEquals(emptyList(), service.getMedia(setOf(MediaType.PHOTO)))
        // The service queries the context's resolver, not one of its own.
        assertEquals(listOf(photo.uri), queriedUris())
    }

    @Test
    fun `factory serves each collection it is given`() = runTest {
        returns(
            FakeCursor.over(emptyMap()).cursor,
            FakeCursor.over(emptyMap()).cursor,
        )

        val service = MediaStoreServiceFactory.create(
            contextOver(Mockito.mock(StorageManager::class.java)),
            setOf(photo, video),
        )

        assertEquals(emptyList(), service.getMedia(setOf(MediaType.PHOTO, MediaType.VIDEO)))
        assertEquals(listOf(photo.uri, video.uri), queriedUris())
    }

    @Test
    fun `factory omits a type it was not given a collection for`() = runTest {
        val context = contextOver(Mockito.mock(StorageManager::class.java))
        val service = MediaStoreServiceFactory.create(context, setOf(photo))

        assertFailsWith<NoSuchElementException> { service.getMedia(setOf(MediaType.VIDEO)) }
        noQuery()
    }

    @Test
    fun `factory asks the context for a storage manager`() {
        val context = contextOver(Mockito.mock(StorageManager::class.java))

        MediaStoreServiceFactory.create(context, setOf(photo))

        Mockito.verify(context).getSystemService(StorageManager::class.java)
    }
}
