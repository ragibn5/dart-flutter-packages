package com.ragibn5.media.provider.media_provider_android.services

import android.database.Cursor
import android.net.Uri
import android.provider.BaseColumns
import android.provider.MediaStore.MediaColumns
import org.mockito.Mockito

/**
 * Column names in a fixed, arbitrary order.
 *
 * Real `MediaStore` column indices are chosen by the device, so tests assert on
 * *which* columns were read rather than on numeric indices.
 */
internal val MEDIA_COLUMN_ORDER: List<String> = listOf(
    BaseColumns._ID,
    MediaColumns.DISPLAY_NAME,
    MediaColumns.MIME_TYPE,
    MediaColumns.SIZE,
    MediaColumns.DATE_ADDED,
    MediaColumns.DATE_MODIFIED,
    MediaColumns.RELATIVE_PATH,
    MediaColumns.IS_PENDING,
    MediaColumns.IS_TRASHED,
    MediaColumns.IS_FAVORITE,
)

private val COLUMN_INDEX: Map<String, Int> =
    MEDIA_COLUMN_ORDER.withIndex().associate { (index, name) -> name to index }

/**
 * A [Cursor] stand-in exposing a single row.
 *
 * `Cursor` is an interface, so a Mockito mock fully substitutes it: this suite
 * never depends on how a real cursor stores or formats values. Omitted columns
 * read as NULL, which is what the plugin's `*OrNull` helpers are for.
 */
internal class FakeCursor internal constructor(
    val cursor: Cursor,
    private val values: Map<String, Any?>,
) {
    /** Columns the code under test resolved, in the order it resolved them. */
    val lookedUpColumns: MutableList<String> = mutableListOf()

    /** True once the code under test closed this cursor. */
    val isClosed: Boolean
        get() = Mockito.mockingDetails(cursor).invocations.any {
            it.method.name == "close"
        }

    private var position = NOT_STARTED

    /**
     * True once, on the first call, so `while (moveToNext())` reads a single
     * row. A cursor with no values has no rows at all.
     */
    fun moveToNext(): Boolean {
        if (position != NOT_STARTED || values.isEmpty()) return false
        position = STARTED
        return true
    }

    companion object {
        private const val NOT_STARTED = -1
        private const val STARTED = 0

        fun over(values: Map<String, Any?>): FakeCursor {
            val cursor = Mockito.mock(Cursor::class.java)
            val fake = FakeCursor(cursor, values)

            COLUMN_INDEX.forEach { (name, index) ->
                Mockito.`when`(cursor.getColumnIndexOrThrow(name)).thenAnswer {
                    fake.lookedUpColumns += name
                    index
                }
                val value = values[name]
                Mockito.`when`(cursor.isNull(index)).thenReturn(value == null)
                if (value == null) return@forEach
                when (value) {
                    is String -> Mockito.`when`(cursor.getString(index)).thenReturn(value)
                    is Number -> {
                        // Stub both readers: `getIntOrNull` reads `getInt`,
                        // the `Long` helpers read `getLong`.
                        Mockito.`when`(cursor.getLong(index)).thenReturn(value.toLong())
                        Mockito.`when`(cursor.getInt(index)).thenReturn(value.toInt())
                    }

                    else -> error("Unsupported column value for '$name': $value")
                }
            }

            Mockito.`when`(cursor.moveToNext()).thenAnswer { fake.moveToNext() }
            return fake
        }
    }
}

/**
 * A [Uri] stand-in. `Uri` is abstract, so identity plus a [toString] is all the
 * production code ever reads.
 */
internal fun fakeUri(value: String): Uri {
    val uri = Mockito.mock(Uri::class.java)
    Mockito.`when`(uri.toString()).thenReturn(value)
    return uri
}
