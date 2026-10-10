package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.FakeItemUriBuilder
import com.ragibn5.media.provider.media_provider_android.fakeFileLocationResolver
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.VolumeInfo
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * [MediaColumnsReader] converts one cursor row into a [com.ragibn5.media.provider.media_provider_android.models.MediaItem].
 *
 * The cursor is a [FakeCursor], the file's location comes from a
 * [fakeFileLocationResolver] and the SDK level is injected, so these tests assert
 * on the reader's own mapping rules only.
 *
 * `volumeInfo` and `relativePath` are both derived from the `DATA` path, so the
 * tests over them pin the resolver rather than the SDK level.
 */
@Suppress("DEPRECATION")
internal class MediaColumnsReaderTest {
    private val collectionUri: Uri = fakeUri("content://media/external/images/media")

    /** A builder that never touches real `ContentUris`. */
    private val uriBuilder = FakeItemUriBuilder()

    /** What [fakeFileLocationResolver] reports for the primary volume. */
    private val primaryVolume = VolumeInfo(isPrimary = true, uuid = null)

    private fun readerOver(
        values: Map<String, Any?>,
        sdkInt: Int = Build.VERSION_CODES.R,
        volumePath: String? = "/storage/emulated/0",
    ) = MediaColumnsReader(
        cursor = FakeCursor.over(values).cursor,
        fileLocationResolver = fakeFileLocationResolver(volumePath = volumePath),
        uriBuilder = uriBuilder,
        sdkInt = sdkInt,
    )

    /** Reads one row as a photo, the type the tests below assert on. */
    private fun MediaColumnsReader.readPhoto() = read(MediaType.PHOTO, collectionUri)

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
                MediaColumns.OWNER_PACKAGE_NAME to "com.android.camera",
                MediaColumns.IS_PENDING to 0,
                MediaColumns.IS_TRASHED to 1,
                MediaColumns.IS_FAVORITE to 1,
                MediaColumns.IS_DOWNLOAD to 1,
            ),
        ).readPhoto()

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
    fun `takes the type and collection uri it was called with`() {
        val item = readerOver(mapOf(BaseColumns._ID to 1L))
            .read(MediaType.VIDEO, collectionUri)

        assertEquals(MediaType.VIDEO, item.type)
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
        ).readPhoto()

        assertEquals(1_700_000_000_000L, item.dateAddedInMillis)
        assertEquals(1_700_000_500_000L, item.dateModifiedInMillis)
        assertEquals(1_700_000_750_000L, item.dateTakenInMillis)
    }

    @Test
    fun `keeps NULL columns null instead of zero`() {
        val item = readerOver(mapOf(BaseColumns._ID to 1L)).readPhoto()

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
        val item = readerOver(mapOf(BaseColumns._ID to 42L)).readPhoto()

        assertEquals("$collectionUri/42", item.uri)
        assertEquals(listOf("$collectionUri/42"), uriBuilder.requestedUris)
    }

    @Test
    fun `reads the base columns on every supported API level`() {
        val item = readerOver(
            values = mapOf(BaseColumns._ID to 1L),
            sdkInt = Build.VERSION_CODES.P,
        ).readPhoto()

        assertEquals("1", item.id)
    }

    @Test
    fun `resolves the volume and relative path from DATA`() {
        val item = readerOver(data("DCIM", "Camera", "cat.png"), Build.VERSION_CODES.P)
            .readPhoto()

        assertEquals(primaryVolume, item.volumeInfo)
        assertEquals("DCIM/Camera/", item.relativePath)
    }

    @Test
    fun `resolves the volume and relative path from DATA on API 29 and above too`() {
        // The columns no longer take part: both fields come from the path.
        val item = readerOver(data("DCIM", "Camera", "cat.png")).readPhoto()

        assertEquals(primaryVolume, item.volumeInfo)
        assertEquals("DCIM/Camera/", item.relativePath)
    }

    @Test
    fun `keeps the volume and relative path null when DATA is missing`() {
        val item = readerOver(
            values = mapOf(BaseColumns._ID to 1L),
            sdkInt = Build.VERSION_CODES.P,
        ).readPhoto()

        assertNull(item.volumeInfo)
        assertNull(item.relativePath)
    }

    @Test
    fun `keeps the volume and relative path null for a file off every volume`() {
        val item = readerOver(
            values = mapOf(
                BaseColumns._ID to 1L,
                MediaColumns.DATA to "/data/media/0/DCIM/cat.png",
            ),
            sdkInt = Build.VERSION_CODES.P,
            // No volume reports a root, so the path cannot be placed.
            volumePath = null,
        ).readPhoto()

        assertNull(item.volumeInfo)
        assertNull(item.relativePath)
    }

    @Test
    fun `does not read the API 29 columns below API 29`() {
        // One below the cutoff, and the cutoff itself, which must have them.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.P + 1).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(
                cursor = cursor.cursor,
                fileLocationResolver = fakeFileLocationResolver(),
                uriBuilder = uriBuilder,
                sdkInt = sdkInt,
            ).readPhoto()

            val expectsApi29 = sdkInt >= Build.VERSION_CODES.Q
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
            cursor = cursor.cursor,
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = uriBuilder,
            sdkInt = Build.VERSION_CODES.Q,
        ).readPhoto()

        assertTrue(MediaColumns.IS_TRASHED !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_FAVORITE !in cursor.lookedUpColumns)
        assertTrue(MediaColumns.IS_DOWNLOAD !in cursor.lookedUpColumns)
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
            .readPhoto()

        assertEquals("$collectionUri/42", item.uri)
        assertEquals(listOf("$collectionUri/42"), uriBuilder.requestedUris)
    }

    @Test
    fun `factory builds a reader at its own API level`() {
        val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

        MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(),
            uriBuilder = uriBuilder,
            // Below API 29, so the API 29 columns must go unread.
            sdkInt = Build.VERSION_CODES.P,
        ).create(cursor.cursor).readPhoto()

        assertTrue(MediaColumns.IS_PENDING !in cursor.lookedUpColumns)
    }

    @Test
    fun `factory builds a reader with its own file location resolver`() {
        val item = MediaColumnsReaderFactory(
            fileLocationResolver = fakeFileLocationResolver(volumePath = null),
            uriBuilder = uriBuilder,
            sdkInt = Build.VERSION_CODES.P,
        ).create(FakeCursor.over(data("DCIM", "cat.png")).cursor)
            .readPhoto()

        assertNull(item.relativePath)
    }

    /**
     * The reader resolves its columns with `getColumnIndexOrThrow`, so a
     * projection missing any of them throws mid-query. Equality — not a subset
     * check — pins that the projection and the reader cannot drift apart, in
     * either direction: a column projected but never read is waste, and one read
     * but not projected is a crash.
     */
    @Test
    fun `the projection is exactly what the reader looks up`() {
        // Each branch, since each level reads a different set.
        listOf(Build.VERSION_CODES.P, Build.VERSION_CODES.R).forEach { sdkInt ->
            val cursor = FakeCursor.over(mapOf(BaseColumns._ID to 1L))

            MediaColumnsReader(
                cursor = cursor.cursor,
                fileLocationResolver = fakeFileLocationResolver(),
                sdkInt = sdkInt,
            )

            assertEquals(
                MediaColumnsReader.projectionFor(sdkInt),
                cursor.lookedUpColumns,
                "projection vs looked-up columns on API $sdkInt",
            )
        }
    }
}