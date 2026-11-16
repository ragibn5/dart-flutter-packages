package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.net.Uri
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

internal class MediaQueryTest {
    private val uri = Mockito.mock(Uri::class.java)

    private fun query(vararg selectionArgs: String) = MediaQuery(
        type = MediaType.PHOTO,
        uri = uri,
        selection = "_data LIKE ?",
        selectionArgs = arrayOf(*selectionArgs),
    )

    @Test
    fun shouldBeEqualIfSelectionArgsHaveSameContent() {
        assertEquals(query("/storage/emulated/0/%"), query("/storage/emulated/0/%"))
    }

    @Test
    fun shouldNotBeEqualIfSelectionArgsDiffer() {
        assertNotEquals(query("/storage/emulated/0/%"), query("/storage/1A2B-3C4D/%"))
    }

    @Test
    fun hashCodeShouldMatchIfSelectionArgsHaveSameContent() {
        assertEquals(query("/storage/emulated/0/%").hashCode(), query("/storage/emulated/0/%").hashCode())
    }
}
