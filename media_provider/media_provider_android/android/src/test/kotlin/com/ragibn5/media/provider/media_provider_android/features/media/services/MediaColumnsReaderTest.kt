package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.database.Cursor
import android.os.Build
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaColumn
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals

@Suppress("DEPRECATION")
internal class MediaColumnsReaderTest {
    /** Every column a reader can read, at the index the fake cursor puts it. */
    private val columns = MediaColumnsReader.projectionFor(Build.VERSION_CODES.R)

    /** A cursor on one row holding [values]; a column left out reads as NULL. */
    private fun cursorOver(values: Map<String, Any>): Cursor = Mockito.mock(Cursor::class.java).also { cursor ->
        columns.forEachIndexed { index, name ->
            Mockito.`when`(cursor.getColumnIndexOrThrow(name)).thenReturn(index)
            val value = values[name]
            Mockito.`when`(cursor.isNull(index)).thenReturn(value == null)
            when (value) {
                is String -> Mockito.`when`(cursor.getString(index)).thenReturn(value)
                is Number -> {
                    Mockito.`when`(cursor.getLong(index)).thenReturn(value.toLong())
                    Mockito.`when`(cursor.getInt(index)).thenReturn(value.toInt())
                }
            }
        }
    }

    private val row = mapOf(
        BaseColumns._ID to 42,
        MediaColumns.DISPLAY_NAME to "IMG_0001.jpg",
        MediaColumns.MIME_TYPE to "image/jpeg",
        MediaColumns.SIZE to 2048,
        MediaColumns.DATE_ADDED to 1_700_000_000,
        MediaColumns.DATE_MODIFIED to 1_700_000_001,
        MediaColumns.DATA to "/storage/emulated/0/DCIM/IMG_0001.jpg",
        MediaColumns.IS_PENDING to 0,
        MediaColumns.DATE_TAKEN to 1_700_000_002_000,
        MediaColumns.OWNER_PACKAGE_NAME to "com.android.camera",
        MediaColumns.IS_TRASHED to 0,
        MediaColumns.IS_FAVORITE to 1,
        MediaColumns.IS_DOWNLOAD to 0,
    )

    @Test
    fun readShouldReadEveryColumnIfApiIs30OrAbove() {
        val column = MediaColumnsReader(cursorOver(row), Build.VERSION_CODES.R).read()

        assertEquals(
            MediaColumn(
                id = "42",
                name = "IMG_0001.jpg",
                mimeType = "image/jpeg",
                sizeInBytes = 2048,
                dateAddedInMillis = 1_700_000_000_000,
                dateModifiedInMillis = 1_700_000_001_000,
                dateTakenInMillis = 1_700_000_002_000,
                ownerPackageName = "com.android.camera",
                data = "/storage/emulated/0/DCIM/IMG_0001.jpg",
                isPending = false,
                isTrashed = false,
                isFavorite = true,
                isDownloaded = false,
            ),
            column,
        )
    }

    @Test
    fun readShouldLeaveApi30ColumnsNullIfApiIs29() {
        val column = MediaColumnsReader(cursorOver(row), Build.VERSION_CODES.Q).read()

        assertEquals(listOf(null, null, null), listOf(column.isTrashed, column.isFavorite, column.isDownloaded))
        assertEquals(false, column.isPending)
    }

    @Test
    fun readShouldLeaveApi29ColumnsNullIfApiIsBelow29() {
        val column = MediaColumnsReader(cursorOver(row), Build.VERSION_CODES.P).read()

        assertEquals(listOf(null, null, null), listOf(column.isPending, column.dateTakenInMillis, column.ownerPackageName))
    }

    @Test
    fun readShouldLeaveDatesNullIfColumnsAreNull() {
        val column = MediaColumnsReader(cursorOver(mapOf(BaseColumns._ID to 42)), Build.VERSION_CODES.R).read()

        assertEquals(listOf(null, null), listOf(column.dateAddedInMillis, column.dateModifiedInMillis))
    }

    @Test
    fun projectionForShouldListBaseColumnsIfApiIsBelow29() {
        assertEquals(
            listOf(
                BaseColumns._ID,
                MediaColumns.DISPLAY_NAME,
                MediaColumns.MIME_TYPE,
                MediaColumns.SIZE,
                MediaColumns.DATE_ADDED,
                MediaColumns.DATE_MODIFIED,
                MediaColumns.DATA,
            ),
            MediaColumnsReader.projectionFor(Build.VERSION_CODES.P),
        )
    }

    @Test
    fun projectionForShouldAddApi29ColumnsIfApiIs29() {
        assertEquals(
            listOf(MediaColumns.IS_PENDING, MediaColumns.DATE_TAKEN, MediaColumns.OWNER_PACKAGE_NAME),
            MediaColumnsReader.projectionFor(Build.VERSION_CODES.Q).drop(7),
        )
    }

    @Test
    fun projectionForShouldAddApi30ColumnsIfApiIs30() {
        assertEquals(
            listOf(MediaColumns.IS_TRASHED, MediaColumns.IS_FAVORITE, MediaColumns.IS_DOWNLOAD),
            MediaColumnsReader.projectionFor(Build.VERSION_CODES.R).drop(10),
        )
    }
}
