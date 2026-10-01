package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeVolumeRoots
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import kotlin.collections.single
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
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
        volumeRoots = fakeVolumeRoots("/storage/emulated/0"),
        dispatcher = UnconfinedTestDispatcher(),
        sdkInt = sdkInt,
        // Injected so no test depends on real `ContentUris` behavior.
        uriBuilder = FakeUriBuilder(),
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

        assertEquals(listOf(photo.uriForVolume, video.uriForVolume), queriedUris())
    }

    @Test
    fun `queries only the requested collection`() = runTest {
        returns(FakeCursor.over(emptyMap()).cursor)

        service().getMedia(setOf(MediaType.VIDEO))

        assertEquals(listOf(video.uriForVolume), queriedUris())
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
            volumeRoots = fakeVolumeRoots("/storage/emulated/0"),
            dispatcher = UnconfinedTestDispatcher(),
            sdkInt = Build.VERSION_CODES.R,
            uriBuilder = FakeUriBuilder(),
        )

        assertFailsWith<NoSuchElementException> { partial.getMedia(setOf(MediaType.VIDEO)) }
        noQuery()
    }
}
