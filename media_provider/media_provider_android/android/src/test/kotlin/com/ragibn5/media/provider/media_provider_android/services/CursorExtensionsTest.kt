package com.ragibn5.media.provider.media_provider_android.services

import android.database.Cursor
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The `*OrNull` helpers exist because `Cursor.getLong` and friends report NULL
 * as `0`, which would hide "unknown". Each test states that mapping rule against
 * a mocked cursor, so none of this depends on a real cursor's storage format.
 */
internal class CursorExtensionsTest {
    private val cursor = Mockito.mock(Cursor::class.java)

    /** Stubs column 0 as holding [value], or NULL when [value] is null. */
    private fun column(value: Any?) = 0.also {
        Mockito.`when`(cursor.isNull(it)).thenReturn(value == null)
        if (value == null) return@also
        when (value) {
            is String -> Mockito.`when`(cursor.getString(it)).thenReturn(value)
            // Stub both readers: `getIntOrNull` reads `getInt`, the `Long`
            // helpers read `getLong`.
            is Number -> {
                Mockito.`when`(cursor.getLong(it)).thenReturn(value.toLong())
                Mockito.`when`(cursor.getInt(it)).thenReturn(value.toInt())
            }

            else -> error("Unsupported column value: $value")
        }
    }

    @Test
    fun `getLongOrNull reads a present value`() {
        assertEquals(99L, cursor.getLongOrNull(column(99L)))
    }

    @Test
    fun `getLongOrNull reports NULL as null, not zero`() {
        assertNull(cursor.getLongOrNull(column(null)))
    }

    @Test
    fun `getIntOrNull reads a present value`() {
        assertEquals(7, cursor.getIntOrNull(column(7L)))
    }

    @Test
    fun `getIntOrNull reports NULL as null, not zero`() {
        assertNull(cursor.getIntOrNull(column(null)))
    }

    @Test
    fun `getStringOrNull reads a present value`() {
        assertEquals("cat.jpg", cursor.getStringOrNull(column("cat.jpg")))
    }

    @Test
    fun `getStringOrNull reports NULL as null`() {
        assertNull(cursor.getStringOrNull(column(null)))
    }

    @Test
    fun `getBooleanOrNull reads zero as false`() {
        assertEquals(false, cursor.getBooleanOrNull(column(0L)))
    }

    @Test
    fun `getBooleanOrNull reads any non-zero as true`() {
        assertEquals(true, cursor.getBooleanOrNull(column(1L)))
        assertEquals(true, cursor.getBooleanOrNull(column(2L)))
    }

    @Test
    fun `getBooleanOrNull reports NULL as null, not false`() {
        assertNull(cursor.getBooleanOrNull(column(null)))
    }

    @Test
    fun `treats only an explicit zero as false`() {
        // Guards the intent above: a NULL must not collapse to `false`.
        assertTrue(cursor.getLongOrNull(column(0L)) == 0L)
        assertFalse(cursor.getLongOrNull(column(null)) == 0L)
    }
}
