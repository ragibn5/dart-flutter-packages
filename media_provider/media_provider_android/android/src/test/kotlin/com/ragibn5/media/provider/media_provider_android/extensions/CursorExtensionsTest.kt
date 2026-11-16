package com.ragibn5.media.provider.media_provider_android.extensions

import android.database.Cursor
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class CursorExtensionsTest {
    private val cursor = Mockito.mock(Cursor::class.java)

    private fun givenNull() {
        Mockito.`when`(cursor.isNull(COLUMN)).thenReturn(true)
    }

    @Test
    fun getLongOrNullShouldReturnNullIfColumnIsNull() {
        givenNull()

        assertNull(cursor.getLongOrNull(COLUMN))
    }

    @Test
    fun getLongOrNullShouldReturnValueIfColumnHasOne() {
        Mockito.`when`(cursor.getLong(COLUMN)).thenReturn(42L)

        assertEquals(42L, cursor.getLongOrNull(COLUMN))
    }

    @Test
    fun getIntOrNullShouldReturnNullIfColumnIsNull() {
        givenNull()

        assertNull(cursor.getIntOrNull(COLUMN))
    }

    @Test
    fun getIntOrNullShouldReturnValueIfColumnHasOne() {
        Mockito.`when`(cursor.getInt(COLUMN)).thenReturn(7)

        assertEquals(7, cursor.getIntOrNull(COLUMN))
    }

    @Test
    fun getStringOrNullShouldReturnNullIfColumnIsNull() {
        givenNull()

        assertNull(cursor.getStringOrNull(COLUMN))
    }

    @Test
    fun getStringOrNullShouldReturnValueIfColumnHasOne() {
        Mockito.`when`(cursor.getString(COLUMN)).thenReturn("IMG_0001.jpg")

        assertEquals("IMG_0001.jpg", cursor.getStringOrNull(COLUMN))
    }

    @Test
    fun getBooleanOrNullShouldReturnNullIfColumnIsNull() {
        givenNull()

        assertNull(cursor.getBooleanOrNull(COLUMN))
    }

    @Test
    fun getBooleanOrNullShouldReturnTrueIfValueIsNotZero() {
        Mockito.`when`(cursor.getInt(COLUMN)).thenReturn(1)

        assertTrue(cursor.getBooleanOrNull(COLUMN)!!)
    }

    @Test
    fun getBooleanOrNullShouldReturnFalseIfValueIsZero() {
        Mockito.`when`(cursor.getInt(COLUMN)).thenReturn(0)

        assertFalse(cursor.getBooleanOrNull(COLUMN)!!)
    }

    private companion object {
        const val COLUMN = 3
    }
}
