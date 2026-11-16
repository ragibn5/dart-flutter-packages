package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaType
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertSame

internal class MediaCollectionUriResolverTest {
    private val photos = Mockito.mock(Uri::class.java)
    private val videos = Mockito.mock(Uri::class.java)
    private val resolver = MediaCollectionUriResolver(photoCollection = { photos }, videoCollection = { videos })

    @Test
    fun collectionForShouldReturnPhotoCollectionIfTypeIsPhoto() {
        assertSame(photos, resolver.collectionFor(MediaType.PHOTO))
    }

    @Test
    fun collectionForShouldReturnVideoCollectionIfTypeIsVideo() {
        assertSame(videos, resolver.collectionFor(MediaType.VIDEO))
    }
}
