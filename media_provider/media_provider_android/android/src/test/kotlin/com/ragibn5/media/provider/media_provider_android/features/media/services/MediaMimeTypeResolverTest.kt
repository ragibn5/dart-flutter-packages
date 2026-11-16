package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ContentResolver
import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals

internal class MediaMimeTypeResolverTest {
    private val contentResolver = Mockito.mock(ContentResolver::class.java)
    private val resolver = MediaMimeTypeResolver(contentResolver)
    private val uri = Mockito.mock(Uri::class.java).also {
        Mockito.`when`(it.toString()).thenReturn("content://media/external/images/media/1")
    }

    @Test
    fun resolveShouldReturnProviderTypeIfUriIsValid() {
        Mockito.`when`(contentResolver.getType(uri)).thenReturn("image/jpeg")

        assertEquals("image/jpeg", resolver.resolve(uri))
    }

    @Test
    fun resolveShouldThrowInvalidRequestWithUriIfUriIsNotValid() {
        Mockito.`when`(contentResolver.getType(uri)).thenThrow(IllegalArgumentException("Unknown URI"))

        val error = assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) { resolver.resolve(uri) }

        assertEquals(mapOf("uri" to "content://media/external/images/media/1"), error.details)
    }
}
