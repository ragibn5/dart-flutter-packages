package com.ragibn5.media.provider.media_provider_android.services

import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeUriBuilder
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * [MediaColumnsReader] converts one cursor row into a [MediaItem].
 *
 * The cursor is a [FakeCursor] and the SDK level is injected, so these tests
 * assert on the reader's own mapping rules only.
 */
internal class MediaColumnsReaderTest {
    private val collection = FakeCollection(MediaType.PHOTO)

    /** A builder that never touches real `ContentUris`. */
    private val uriBuilder = FakeUriBuilder()

    private fun readerOver(
        values: Map<String, Any?>,
        sdkInt: Int = Build.VERSION_CODES.R,
    ) = MediaColumnsReader(FakeCursor.over(values).cursor, sdkInt, uriBuilder)

    @Test
    fun `maps every column onto the item`() {
        val item = readerOver(
            mapOf(
                BaseColumns._ID to 42L,
                MediaColumns.DISPLAY_NAME to "cat.png",
                MediaColumns.MIME_TYPE to "image/png",
                MediaColumns.SIZE to 2048L,
                MediaColumns.DATE_ADDED to 1_700_000_000L,
                MediaColumns.DATE_MODIFIED to 1_700_000_500L,
                MediaColumns.RELATIVE_PATH to "Pictures/",
                MediaColumns.IS_PENDING to 0,
                MediaColumns.IS_TRASHED to 1,
                MediaColumns.IS_FAVORITE to 1,
            ),
        ).read(collection)

        assertEquals(MediaType.PHOTO, item.type)
        assertEquals("42", item.id)
        assertEquals("cat.png", item.name)
        assertEquals("image/png", item.mimeType)
        assertEquals(2048L, item.sizeInBytes)
        assertEquals("Pictures/", item.relativePath)
        assertEquals(false, item.isPending)
        assertEquals(true, item.isTrashed)
        assertEquals(true, item.isFavorite)
    }

    @Test
    fun `converts second-based dates to milliseconds`() {
        val item = readerOver(
            mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATE_ADDED to 1_700_000_000L,
                MediaColumns.DATE_MODIFIED to 1_700_000_500L,
            ),
        ).read(collection)

        assertEquals(1_700_000_000_000L, item.dateAddedInMillis)
        assertEquals(1_700_000_500_000L, item.dateModifiedInMillis)
    }

    @Test
    fun `keeps NULL columns null instead of zero`() {
        val item = readerOver(mapOf(BaseColumns._ID to 1L)).read(collection)

        assertNull(item.name)
        assertNull(item.mimeType)
        assertNull(item.sizeInBytes)
        assertNull(item.dateAddedInMillis)
        assertNull(item.dateModifiedInMillis)
    }

    @Test
    fun `builds the item uri from the collection uri and the row id`() {
        val item = readerOver(mapOf(BaseColumns._ID to 42L)).read(collection)

        assertEquals("${collection.uri}/42", item.uri)
        assertEquals(listOf("${collection.uri}/42"), uriBuilder.requestedUris)
    }

    @Test
    fun `reads the base columns on every supported API level`() {
        val item = readerOver(
            values = mapOf(BaseColumns._ID to 1L),
            sdkInt = Build.VERSION_CODES.P,
        ).read(collection)

        assertEquals("1", item.id)
    }

    @Test
    fun `reads the API 29 and 30 columns on API 30 and above`() {
        val item = readerOver(
            values = mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.RELATIVE_PATH to "DCIM/",
                MediaColumns.IS_PENDING to 1,
                MediaColumns.IS_TRASHED to 1,
                MediaColumns.IS_FAVORITE to 0,
            ),
            sdkInt = Build.VERSION_CODES.R,
        ).read(collection)

        assertEquals("DCIM/", item.relativePath)
        assertEquals(true, item.isPending)
        assertEquals(true, item.isTrashed)
        assertEquals(false, item.isFavorite)
    }

    @Test
    fun `does not read the API 29 columns below API 29`() {
        // One below the cutoff, and the cutoff itself, which must have them.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.P + 1).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(cursor.cursor, sdkInt, uriBuilder).read(collection)

            val expectsApi29 = sdkInt >= Build.VERSION_CODES.Q
            assertEquals(
                expectsApi29,
                MediaColumns.RELATIVE_PATH in cursor.lookedUpColumns,
                "RELATIVE_PATH on API $sdkInt",
            )
            assertEquals(
                expectsApi29,
                MediaColumns.IS_PENDING in cursor.lookedUpColumns,
                "IS_PENDING on API $sdkInt",
            )
        }
    }

    @Test
    fun `does not read the API 30 columns below API 30`() {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

        MediaColumnsReader(cursor.cursor, Build.VERSION_CODES.Q, uriBuilder).read(collection)

        assertTrue(MediaColumns.IS_TRASHED !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_FAVORITE !in cursor.lookedUpColumns)
    }

    @Test
    fun `requests exactly the projection it reads`() {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

        MediaColumnsReader(cursor.cursor, Build.VERSION_CODES.R, uriBuilder).read(collection)

        assertEquals(
            MediaColumnsReader.projectionFor(Build.VERSION_CODES.R),
            cursor.lookedUpColumns
        )
    }
}
