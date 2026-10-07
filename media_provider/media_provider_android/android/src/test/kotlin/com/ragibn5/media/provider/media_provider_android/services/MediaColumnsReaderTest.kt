package com.ragibn5.media.provider.media_provider_android.services

import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeFileLocationResolver
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * [MediaColumnsReader] converts one cursor row into a [com.ragibn5.media.provider.media_provider_android.models.MediaItem].
 *
 * The cursor is a [FakeCursor], the file locations come from a
 * [fakeFileLocationResolver] and the SDK level is injected, so these tests assert
 * on the reader's own mapping rules only.
 *
 * `volumeName` and `relativePath` come from the `VOLUME_NAME` and `RELATIVE_PATH`
 * columns on API 29 and above, and from the `DATA` path below that level or when
 * those columns are NULL, so tests over them pin the SDK level too.
 */
@Suppress("DEPRECATION")
internal class MediaColumnsReaderTest {
    private val collection = FakeCollection(MediaType.PHOTO)

    /** A builder that never touches real `ContentUris`. */
    private val uriBuilder = FakeUriBuilder()

    private fun readerOver(
        values: Map<String, Any?>,
        sdkInt: Int = Build.VERSION_CODES.R,
        volumePath: String? = "/storage/emulated/0",
    ) = MediaColumnsReader(
        FakeCursor.over(values).cursor,
        fakeFileLocationResolver(volumePath = volumePath),
        uriBuilder,
        sdkInt,
    )

    /** A `DATA` path under the volume [fakeFileLocationResolver] reports. */
    private fun data(vararg segments: String) =
        mapOf(MediaColumns.DATA to "/storage/emulated/0/${segments.joinToString("/")}")

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
                MediaColumns.DATE_TAKEN to 1_700_000_750_000L,
                MediaColumns.VOLUME_NAME to "external_primary",
                MediaColumns.RELATIVE_PATH to "Pictures/",
                MediaColumns.OWNER_PACKAGE_NAME to "com.android.camera",
                MediaColumns.IS_PENDING to 0,
                MediaColumns.IS_TRASHED to 1,
                MediaColumns.IS_FAVORITE to 1,
                MediaColumns.IS_DOWNLOAD to 1,
            ),
        ).read(collection)

        assertEquals(MediaType.PHOTO, item.type)
        assertEquals("42", item.id)
        assertEquals("cat.png", item.name)
        assertEquals("image/png", item.mimeType)
        assertEquals(2048L, item.sizeInBytes)
        assertEquals(1_700_000_000_000L, item.dateAddedInMillis)
        assertEquals(1_700_000_500_000L, item.dateModifiedInMillis)
        assertEquals(1_700_000_750_000L, item.dateTakenInMillis)
        assertEquals("com.android.camera", item.ownerPackageName)
        assertEquals(false, item.isPending)
        assertEquals(true, item.isTrashed)
        assertEquals(true, item.isFavorite)
        assertEquals(true, item.isDownloaded)
    }

    @Test
    fun `converts second-based dates to milliseconds`() {
        val item = readerOver(
            mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATE_ADDED to 1_700_000_000L,
                MediaColumns.DATE_MODIFIED to 1_700_000_500L,
                // DATE_TAKEN is already milliseconds and must pass through untouched.
                MediaColumns.DATE_TAKEN to 1_700_000_750_000L,
            ),
        ).read(collection)

        assertEquals(1_700_000_000_000L, item.dateAddedInMillis)
        assertEquals(1_700_000_500_000L, item.dateModifiedInMillis)
        assertEquals(1_700_000_750_000L, item.dateTakenInMillis)
    }

    @Test
    fun `keeps NULL columns null instead of zero`() {
        val item = readerOver(mapOf(BaseColumns._ID to 1L)).read(collection)

        assertNull(item.name)
        assertNull(item.mimeType)
        assertNull(item.sizeInBytes)
        assertNull(item.dateAddedInMillis)
        assertNull(item.dateModifiedInMillis)
        assertNull(item.dateTakenInMillis)
        assertNull(item.ownerPackageName)
        assertNull(item.isDownloaded)
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
    fun `resolves the volume name and relative path from DATA`() {
        val item = readerOver(data("DCIM", "Camera", "cat.png"), Build.VERSION_CODES.P)
            .read(collection)

        // The primary volume is named, and the path is relative to its root.
        assertEquals(MediaStore.VOLUME_EXTERNAL_PRIMARY, item.volumeName)
        assertEquals("DCIM/Camera/", item.relativePath)
    }

    @Test
    fun `keeps the volume name and relative path null when DATA is missing`() {
        val item = readerOver(
            values = mapOf(BaseColumns._ID to 1L),
            sdkInt = Build.VERSION_CODES.P,
        ).read(collection)

        assertNull(item.volumeName)
        assertNull(item.relativePath)
    }

    @Test
    fun `keeps the volume name and relative path null for a file off every volume`() {
        val item = readerOver(
            values = mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/data/media/0/DCIM/cat.png",
            ),
            sdkInt = Build.VERSION_CODES.P,
            // No volume reports a root, so the path cannot be placed.
            volumePath = null,
        ).read(collection)

        assertNull(item.volumeName)
        assertNull(item.relativePath)
    }

    @Test
    fun `reports the lowercased volume UUID for a secondary volume`() {
        val item = MediaColumnsReader(
            FakeCursor.over(data("DCIM", "cat.png")).cursor,
            fakeFileLocationResolver(
                isPrimary = false,
                uuid = "1A2B-3C4D",
                sdkInt = Build.VERSION_CODES.P,
            ),
            uriBuilder,
            Build.VERSION_CODES.P,
        ).read(collection)

        assertEquals("1a2b-3c4d", item.volumeName)
        assertEquals("DCIM/", item.relativePath)
    }

    @Test
    fun `prefers the column-sourced paths over the resolved ones on API 29 and above`() {
        val item = readerOver(
            mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/storage/emulated/0/DCIM/Camera/cat.png",
                MediaColumns.VOLUME_NAME to "external_primary",
                MediaColumns.RELATIVE_PATH to "Pictures/",
            ),
        ).read(collection)

        assertEquals("external_primary", item.volumeName)
        assertEquals("Pictures/", item.relativePath)
    }

    @Test
    fun `falls back to the resolved paths when the columns are NULL`() {
        val item = readerOver(
            mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/storage/emulated/0/DCIM/Camera/cat.png",
            ),
        ).read(collection)

        assertEquals(MediaStore.VOLUME_EXTERNAL_PRIMARY, item.volumeName)
        assertEquals("DCIM/Camera/", item.relativePath)
    }

    @Test
    fun `reads the API 29 and 30 columns on API 30 and above`() {
        val item = readerOver(
            values = mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.VOLUME_NAME to "external_primary",
                MediaColumns.RELATIVE_PATH to "DCIM/",
                MediaColumns.IS_PENDING to 1,
                MediaColumns.IS_TRASHED to 1,
                MediaColumns.IS_FAVORITE to 0,
                MediaColumns.DATE_TAKEN to 1_700_000_750_000L,
                MediaColumns.OWNER_PACKAGE_NAME to "com.android.camera",
                MediaColumns.IS_DOWNLOAD to 0,
            ),
            sdkInt = Build.VERSION_CODES.R,
        ).read(collection)

        assertEquals(true, item.isPending)
        assertEquals(true, item.isTrashed)
        assertEquals(false, item.isFavorite)
        assertEquals(1_700_000_750_000L, item.dateTakenInMillis)
        assertEquals("com.android.camera", item.ownerPackageName)
        assertEquals(false, item.isDownloaded)
    }

    @Test
    fun `does not read the API 29 columns below API 29`() {
        // One below the cutoff, and the cutoff itself, which must have them.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.P + 1).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(
                cursor.cursor,
                fakeFileLocationResolver(),
                uriBuilder,
                sdkInt,
            ).read(collection)

            val expectsApi29 = sdkInt >= Build.VERSION_CODES.Q
            assertEquals(
                expectsApi29,
                MediaColumns.VOLUME_NAME in cursor.lookedUpColumns,
                "VOLUME_NAME on API $sdkInt",
            )
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
            assertEquals(
                expectsApi29,
                MediaColumns.DATE_TAKEN in cursor.lookedUpColumns,
                "DATE_TAKEN on API $sdkInt",
            )
            assertEquals(
                expectsApi29,
                MediaColumns.OWNER_PACKAGE_NAME in cursor.lookedUpColumns,
                "OWNER_PACKAGE_NAME on API $sdkInt",
            )
        }
    }

    @Test
    fun `does not read the API 30 columns below API 30`() {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

        MediaColumnsReader(
            cursor.cursor, fakeFileLocationResolver(), uriBuilder, Build.VERSION_CODES.Q,
        ).read(collection)

        assertTrue(MediaColumns.IS_TRASHED !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_FAVORITE !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_DOWNLOAD !in cursor.lookedUpColumns)
    }

    @Test
    fun `requests exactly the projection it reads`() {
        // Both branches, since each API level reads a different set of columns.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.R).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(
                cursor.cursor, fakeFileLocationResolver(), uriBuilder, sdkInt,
            ).read(collection)

            assertEquals(
                MediaColumnsReader.projectionFor(sdkInt),
                cursor.lookedUpColumns,
                "projection on API $sdkInt",
            )
        }
    }

    /**
     * [MediaColumnsReaderFactory] holds the dependencies a
     * [MediaStoreServiceImpl](com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceImpl)
     * cannot pass on per query, so these tests assert it forwards each of them to
     * the reader it creates rather than falling back to a device default.
     */
    @Test
    fun `factory builds a reader with its own uri builder`() {
        val item = MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = uriBuilder,
            sdkInt = Build.VERSION_CODES.R,
        ).create(FakeCursor.over(mapOf(BaseColumns._ID to 42L)).cursor)
            .read(collection)

        assertEquals("${collection.uri}/42", item.uri)
        assertEquals(listOf("${collection.uri}/42"), uriBuilder.requestedUris)
    }

    @Test
    fun `factory builds a reader at its own API level`() {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

        MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = uriBuilder,
            // Below API 29, so the API 29 columns must go unread.
            sdkInt = Build.VERSION_CODES.P,
        ).create(cursor.cursor).read(collection)

        assertTrue(MediaColumns.RELATIVE_PATH !in cursor.lookedUpColumns)
    }

    @Test
    fun `factory builds a reader with its own file location resolver`() {
        val item = MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(volumePath = null),
            uriBuilder = uriBuilder,
            sdkInt = Build.VERSION_CODES.P,
        ).create(FakeCursor.over(data("DCIM", "cat.png")).cursor)
            .read(collection)

        assertNull(item.relativePath)
    }

    @Test
    fun `the default projection matches the API level the reader reads`() {
        assertEquals(
            MediaColumnsReader.projectionFor(Build.VERSION.SDK_INT),
            MediaColumnsReader.projection,
        )
    }
}
