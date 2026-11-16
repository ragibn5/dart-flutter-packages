package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaColumnsReaderFactory
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaType
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeSpec
import com.ragibn5.media.provider.media_provider_android.features.volume.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.testing.anyOf
import com.ragibn5.media.provider.media_provider_android.testing.primaryVolumeIdentity
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class MediaQueryServiceTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val fileLocationResolver = Mockito.mock(FileLocationResolver::class.java)
    private val queryBuilder = Mockito.mock(MediaQueryBuilder::class.java)
    private val uriBuilder = Mockito.mock(MediaItemUriBuilder::class.java)
    private val readerFactory = Mockito.mock(MediaColumnsReaderFactory::class.java)

    private val photos = Mockito.mock(Uri::class.java)
    private val videos = Mockito.mock(Uri::class.java)
    private val spec = QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.Primary()))
    private val location = FileLocation(primaryVolumeIdentity, "DCIM/", "IMG_0042.jpg")

    init {
        Mockito.`when`(readerFactory.projection).thenReturn(listOf("_id"))
        Mockito.`when`(uriBuilder.build(anyOf(Uri::class.java), Mockito.anyLong())).thenAnswer {
            "content://media/${it.arguments[1]}"
        }
    }

    private fun service(scheduler: kotlinx.coroutines.test.TestCoroutineScheduler) = MediaQueryServiceImpl(
        contentResolver = contentResolver,
        fileLocationResolver = fileLocationResolver,
        mediaQueryBuilder = queryBuilder,
        mediaItemUriBuilder = uriBuilder,
        mediaColumnsReaderFactory = readerFactory,
        dispatcher = UnconfinedTestDispatcher(scheduler),
    )

    private fun query(type: MediaType, uri: Uri) = MediaQuery(type, uri, "_data LIKE ?", arrayOf("/storage/%"))

    private fun column(id: String, data: String?) = MediaColumn(
        id = id,
        name = "IMG_$id.jpg",
        mimeType = "image/jpeg",
        sizeInBytes = 2048,
        dateAddedInMillis = 1_000,
        dateModifiedInMillis = 2_000,
        dateTakenInMillis = 3_000,
        ownerPackageName = "com.android.camera",
        data = data,
        isPending = false,
        isTrashed = false,
        isFavorite = true,
        isDownloaded = false,
    )

    /** Makes [uri] answer with a cursor on one row, read as [row]; returns the cursor. */
    private fun givenRow(uri: Uri, row: MediaColumn): Cursor {
        val cursor = Mockito.mock(Cursor::class.java)
        Mockito.`when`(cursor.moveToNext()).thenReturn(true, false)
        val reader = Mockito.mock(MediaColumnsReader::class.java)
        Mockito.`when`(reader.read()).thenReturn(row)
        Mockito.`when`(readerFactory.create(cursor)).thenReturn(reader)
        Mockito.`when`(
            contentResolver.query(
                Mockito.eq(uri),
                anyOf(Array<String>::class.java),
                Mockito.anyString(),
                anyOf(Array<String>::class.java),
                Mockito.isNull(),
            ),
        ).thenReturn(cursor)
        return cursor
    }

    @Test
    fun queryMediaShouldReturnEmptyWithoutQueryingIfTypesAreEmpty() = runTest {
        assertEquals(emptyList(), service(testScheduler).queryMedia(spec.copy(types = emptySet())))
        Mockito.verifyNoInteractions(contentResolver)
    }

    @Test
    fun queryMediaShouldReturnEmptyWithoutQueryingIfVolumesAreEmpty() = runTest {
        assertEquals(emptyList(), service(testScheduler).queryMedia(spec.copy(volumes = emptySet())))
        Mockito.verifyNoInteractions(contentResolver)
    }

    @Test
    fun queryMediaShouldReturnItemWithUriAndFileLocationForEachRow() = runTest {
        Mockito.`when`(queryBuilder.build(spec)).thenReturn(listOf(query(MediaType.PHOTO, photos)))
        givenRow(photos, column("42", data = "/storage/emulated/0/DCIM/IMG_0042.jpg"))
        Mockito.`when`(fileLocationResolver.resolve("/storage/emulated/0/DCIM/IMG_0042.jpg")).thenReturn(location)

        assertEquals(
            listOf(
                MediaItem(
                    type = MediaType.PHOTO,
                    uri = "content://media/42",
                    fileLocation = location,
                    id = "42",
                    name = "IMG_42.jpg",
                    mimeType = "image/jpeg",
                    sizeInBytes = 2048,
                    dateAddedInMillis = 1_000,
                    dateModifiedInMillis = 2_000,
                    dateTakenInMillis = 3_000,
                    ownerPackageName = "com.android.camera",
                    data = "/storage/emulated/0/DCIM/IMG_0042.jpg",
                    isPending = false,
                    isTrashed = false,
                    isFavorite = true,
                    isDownloaded = false,
                ),
            ),
            service(testScheduler).queryMedia(spec),
        )
    }

    @Test
    fun queryMediaShouldGiveNoFileLocationIfRowHasNoData() = runTest {
        Mockito.`when`(queryBuilder.build(spec)).thenReturn(listOf(query(MediaType.PHOTO, photos)))
        givenRow(photos, column("42", data = null))

        assertNull(service(testScheduler).queryMedia(spec).single().fileLocation)
    }

    @Test
    fun queryMediaShouldJoinItemsOfEveryQueryInOrder() = runTest {
        Mockito.`when`(queryBuilder.build(spec))
            .thenReturn(listOf(query(MediaType.PHOTO, photos), query(MediaType.VIDEO, videos)))
        givenRow(photos, column("1", data = null))
        givenRow(videos, column("2", data = null))

        assertEquals(
            listOf(MediaType.PHOTO to "1", MediaType.VIDEO to "2"),
            service(testScheduler).queryMedia(spec).map { it.type to it.id },
        )
    }

    @Test
    fun queryMediaShouldSkipQueryIfProviderReturnsNoCursor() = runTest {
        Mockito.`when`(queryBuilder.build(spec)).thenReturn(listOf(query(MediaType.PHOTO, photos)))

        assertEquals(emptyList(), service(testScheduler).queryMedia(spec))
    }

    @Test
    fun queryMediaShouldCloseCursorIfRowsAreRead() = runTest {
        Mockito.`when`(queryBuilder.build(spec)).thenReturn(listOf(query(MediaType.PHOTO, photos)))
        val cursor = givenRow(photos, column("42", data = null))

        service(testScheduler).queryMedia(spec)

        Mockito.verify(cursor).close()
    }
}
