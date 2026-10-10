package com.ragibn5.media.provider.media_provider_android.services

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeItemUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeFileLocationResolver
import com.ragibn5.media.provider.media_provider_android.fakeStorageManager
import com.ragibn5.media.provider.media_provider_android.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.models.VolumeSpec
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
 * [MediaStoreServiceImpl] runs the queries a [MediaQueryBuilder] hands it and
 * turns the rows that come back into
 * [com.ragibn5.media.provider.media_provider_android.models.MediaItem]s.
 *
 * The `ContentResolver` and the builder are mocked and the SDK level is injected,
 * so these tests describe the service's own rules. The builder is mocked rather
 * than real because the collection URIs it produces come from `MediaStore`, whose
 * constants are `null` off-device; [MediaQueryBuilder] is covered by
 * `MediaQueryBuilderTest` over injected volumes instead.
 */
@OptIn(ExperimentalCoroutinesApi::class)
internal class MediaStoreServiceImplTest {
    private val contentResolver: ContentResolver = Mockito.mock(ContentResolver::class.java)
    private val queryBuilder: MediaQueryBuilder = Mockito.mock(MediaQueryBuilder::class.java)

    /** The URIs the builder hands back, one per type. */
    private val photoUri: Uri = fakeUri("content://test/photo")
    private val videoUri: Uri = fakeUri("content://test/video")

    private fun service(sdkInt: Int = Build.VERSION_CODES.R) = MediaStoreServiceImpl(
        contentResolver = contentResolver,
        queryBuilder = queryBuilder,
        // The `uriBuilder` is injected so no test depends on real `ContentUris`
        // behavior, and the reader is pinned to the same API level as the query.
        mediaColumnsReaderFactory = MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = FakeItemUriBuilder(),
            sdkInt = sdkInt,
        ),
        dispatcher = UnconfinedTestDispatcher(),
        sdkInt = sdkInt,
    )

    private fun spec(
        types: Set<MediaType> = setOf(MediaType.PHOTO),
        volumes: Set<VolumeSpec> = setOf(VolumeSpec.Primary),
    ) = QuerySpec(types = types, volumes = volumes)

    /**
     * The queries [MediaQueryBuilder] hands back, whatever spec it is given.
     *
     * `any()` returns null, which `build` rejects as a non-null parameter, so the
     * matcher returns a stand-in spec instead.
     */
    private fun builds(vararg queries: MediaQuery) {
        Mockito.`when`(queryBuilder.build(Mockito.any(QuerySpec::class.java) ?: spec()))
            .thenReturn(queries.toList())
    }

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

    /** A query over [uri], as [MediaQueryBuilder] would hand one over. */
    private fun queryOver(uri: Uri, type: MediaType = MediaType.PHOTO) = MediaQuery(
        type = type,
        uri = uri,
        selection = null,
        selectionArgs = null,
    )

    @Test
    fun `returns an empty list without querying when no types are requested`() = runTest {
        assertEquals(emptyList(), service().getMedia(spec(types = emptySet())))
        noQuery()
    }

    @Test
    fun `returns an empty list without querying when no volumes are requested`() = runTest {
        assertEquals(emptyList(), service().getMedia(spec(volumes = emptySet())))
        noQuery()
    }

    @Test
    fun `returns an empty list without querying when the builder yields nothing`() = runTest {
        // No requested volume is mounted, so there is nothing to query.
        builds()

        assertEquals(emptyList(), service().getMedia(spec()))
        noQuery()
    }

    @Test
    fun `passes the spec to the builder untouched`() = runTest {
        val requested = spec(types = setOf(MediaType.PHOTO, MediaType.VIDEO))
        Mockito.`when`(queryBuilder.build(requested)).thenReturn(listOf(queryOver(photoUri)))

        service().getMedia(requested)

        Mockito.verify(queryBuilder).build(requested)
    }

    @Test
    fun `queries each query the builder yields`() = runTest {
        builds(queryOver(photoUri), queryOver(videoUri, MediaType.VIDEO))
        returns(FakeCursor.over(emptyMap()).cursor, FakeCursor.over(emptyMap()).cursor)

        service().getMedia(spec())

        assertEquals(listOf(photoUri, videoUri), queriedUris())
    }

    @Test
    fun `passes each query's selection through`() = runTest {
        val query = MediaQuery(
            type = MediaType.PHOTO,
            uri = photoUri,
            selection = "${MediaColumns.DATA} LIKE ?",
            selectionArgs = arrayOf("/storage/emulated/0%"),
        )
        builds(query)
        returns(FakeCursor.over(emptyMap()).cursor)

        service().getMedia(spec())

        val selection = ArgumentCaptor.forClass(String::class.java)
        val args = ArgumentCaptor.forClass(Array<String>::class.java)
        Mockito.verify(contentResolver).query(
            Mockito.any(),
            Mockito.any(),
            selection.capture(),
            args.capture(),
            Mockito.any(),
        )
        assertEquals("${MediaColumns.DATA} LIKE ?", selection.value)
        // Arrays compare by identity, so compare their contents.
        assertEquals(listOf("/storage/emulated/0%"), args.value.toList())
    }

    @Test
    fun `requests the projection for the given API level`() = runTest {
        builds(queryOver(photoUri))
        returns(FakeCursor.over(emptyMap()).cursor)

        service(sdkInt = Build.VERSION_CODES.P).getMedia(spec())

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
    fun `stamps each item with the type of the query it came from`() = runTest {
        builds(queryOver(videoUri, MediaType.VIDEO))
        returns(FakeCursor.over(mapOf(BaseColumns._ID to 2L)).cursor)

        val items = service().getMedia(spec())

        assertEquals(MediaType.VIDEO, items.single().type)
    }

    @Test
    fun `maps each row of the cursor onto a media item`() = runTest {
        builds(queryOver(photoUri))
        val cursor = FakeCursor.over(
            mapOf(BaseColumns._ID to 7L, MediaColumns.DISPLAY_NAME to "cat.jpg"),
        )
        returns(cursor.cursor)

        val items = service().getMedia(spec())

        assertEquals(1, items.size)
        assertEquals("7", items.single().id)
        assertEquals(MediaType.PHOTO, items.single().type)
    }

    @Test
    fun `concatenates the rows of every query`() = runTest {
        builds(queryOver(photoUri), queryOver(videoUri, MediaType.VIDEO))
        returns(
            FakeCursor.over(mapOf(BaseColumns._ID to 1L)).cursor,
            FakeCursor.over(mapOf(BaseColumns._ID to 2L)).cursor,
        )

        val items = service().getMedia(spec())

        assertEquals(listOf("1", "2"), items.map { it.id })
    }

    @Test
    fun `closes the cursor after reading it`() = runTest {
        builds(queryOver(photoUri))
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        returns(cursor.cursor)

        service().getMedia(spec())

        assertTrue(cursor.isClosed, "the cursor must be closed")
    }

    @Test
    fun `closes the cursor even when reading a row fails`() = runTest {
        builds(queryOver(photoUri))
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        Mockito.`when`(cursor.cursor.getLong(Mockito.anyInt()))
            .thenThrow(IllegalStateException("boom"))
        returns(cursor.cursor)

        assertFailsWith<IllegalStateException> { service().getMedia(spec()) }

        assertTrue(cursor.isClosed, "the cursor must be closed even on failure")
    }

    @Test
    fun `returns an empty list when the query yields no cursor`() = runTest {
        builds(queryOver(photoUri))
        returns(null)

        assertEquals(emptyList(), service().getMedia(spec()))
    }

    @Test
    fun `returns an empty list when the cursor has no rows`() = runTest {
        builds(queryOver(photoUri))
        returns(FakeCursor.over(emptyMap()).cursor)

        assertEquals(emptyList(), service().getMedia(spec()))
    }

    /**
     * [MediaStoreServiceFactory] is the one place the plugin's object graph is
     * assembled, so this asserts the wiring rather than the querying: the context
     * is asked for the storage manager the volume lookups go through, and the
     * service it builds is served over the context's resolver.
     *
     * Only the assembly is covered, not a query it produces: the factory pins
     * `Build.VERSION.SDK_INT`, which is `0` off-device and so would take the
     * pre-API 30 volume paths, which read the real environment.
     */
    @Test
    fun `factory asks the context for a storage manager`() {
        // Stubbed up front: a mock called on while another's stubbing is open is
        // read as a stubbing of its own.
        val storageManager = fakeStorageManager(emptyList())
        val context = Mockito.mock(Context::class.java)
        Mockito.`when`(context.getSystemService(StorageManager::class.java))
            .thenReturn(storageManager)
        Mockito.`when`(context.contentResolver).thenReturn(contentResolver)

        val service = MediaStoreServiceFactory.create(context)

        assertIs<MediaStoreServiceImpl>(service)
        Mockito.verify(context).getSystemService(StorageManager::class.java)
    }
}
