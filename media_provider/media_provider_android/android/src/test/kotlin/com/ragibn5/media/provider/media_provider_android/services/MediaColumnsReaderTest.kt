package com.ragibn5.media.provider.media_provider_android.services

import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeVolumeRoots
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import java.util.concurrent.atomic.AtomicInteger
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
@Suppress("DEPRECATION")
internal class MediaColumnsReaderTest {
    private val collection = FakeCollection(MediaType.PHOTO)

    /** A builder that never touches real `ContentUris`. */
    private val uriBuilder = FakeUriBuilder()

    /** Volume roots a fake row can sit under, for the levels below API 29. */
    private val volumeRoots = fakeVolumeRoots("/storage/emulated/0")

    private fun readerOver(
        values: Map<String, Any?>,
        sdkInt: Int = Build.VERSION_CODES.R,
    ) = MediaColumnsReader(
        FakeCursor.over(values).cursor,
        sdkInt,
        uriBuilder,
        volumeRoots,
    )

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

        assertEquals("${collection.uriForVolume}/42", item.uri)
        assertEquals(listOf("${collection.uriForVolume}/42"), uriBuilder.requestedUris)
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

            MediaColumnsReader(cursor.cursor, sdkInt, uriBuilder, volumeRoots)
                .read(collection)

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

        MediaColumnsReader(
            cursor.cursor, Build.VERSION_CODES.Q, uriBuilder, volumeRoots,
        ).read(collection)

        assertTrue(MediaColumns.IS_TRASHED !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_FAVORITE !in cursor.lookedUpColumns)
    }

    @Test
    fun `derives the relative path from DATA below API 29`() {
        val cursor = FakeCursor.over(
            mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/storage/emulated/0/DCIM/Camera/cat.png",
            ),
        )

        val item = MediaColumnsReader(
            cursor.cursor, Build.VERSION_CODES.P, uriBuilder, volumeRoots,
        ).read(collection)

        assertEquals("DCIM/Camera/", item.relativePath)
        assertTrue(MediaColumns.RELATIVE_PATH !in cursor.lookedUpColumns)
    }

    @Test
    fun `keeps the relative path null below API 29 when DATA is missing`() {
        val item = readerOver(
            values = mapOf(BaseColumns._ID to 1L),
            sdkInt = Build.VERSION_CODES.P,
        ).read(collection)

        assertNull(item.relativePath)
    }

    @Test
    fun `keeps the relative path null below API 29 for a file off every volume`() {
        val item = readerOver(
            values = mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/data/media/0/DCIM/cat.png",
            ),
            sdkInt = Build.VERSION_CODES.P,
        ).read(collection)

        assertNull(item.relativePath)
    }

    @Test
    fun `asks for the volume roots once per query, and never above API 29`() {
        val asked = AtomicInteger()
        fun countingRoots() = MediaVolumeRoots {
            asked.incrementAndGet()
            listOf("/storage/emulated/0")
        }

        val modern = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        MediaColumnsReader(
            modern.cursor, Build.VERSION_CODES.R, uriBuilder, countingRoots(),
        ).read(collection)
        assertEquals(0, asked.get())

        val legacy = FakeCursor.over(mapOf(BaseColumns._ID to 1L))
        MediaColumnsReader(
            legacy.cursor, Build.VERSION_CODES.P, uriBuilder, countingRoots(),
        ).read(collection)
        assertEquals(1, asked.get())
    }

    @Test
    fun `does not read DATA on API 29 and above`() {
        listOf(Build.VERSION_CODES.Q, Build.VERSION_CODES.R).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(cursor.cursor, sdkInt, uriBuilder, volumeRoots)
                .read(collection)

            assertTrue(
                MediaColumns.DATA !in cursor.lookedUpColumns,
                "DATA on API $sdkInt",
            )
        }
    }

    @Test
    fun `requests exactly the projection it reads`() {
        // Both branches, since each API level reads a different relative path
        // column.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.R).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(cursor.cursor, sdkInt, uriBuilder, volumeRoots)
                .read(collection)

            assertEquals(
                MediaColumnsReader.projectionFor(sdkInt),
                cursor.lookedUpColumns,
                "projection on API $sdkInt",
            )
        }
    }
}
