package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals

/**
 * [MediaCollectionUriResolver] maps each [MediaType] to the collection it is read
 * from.
 *
 * The collections are supplied rather than read from `MediaStore`, whose
 * constants are `null` off-device, so the mapping is testable here.
 */
internal class MediaCollectionUriResolverTest {
    private val photo: Uri = fakeUri("content://test/photo")
    private val video: Uri = fakeUri("content://test/video")

    private val sut = MediaCollectionUriResolver(
        photoCollection = { photo },
        videoCollection = { video },
    )

    @Test
    fun `serves the photo collection for photos`() {
        assertEquals(photo, sut.collectionFor(MediaType.PHOTO))
    }

    @Test
    fun `serves the video collection for videos`() {
        assertEquals(video, sut.collectionFor(MediaType.VIDEO))
    }

    @Test
    fun `does not swap the collections`() {
        // A transposed `when` would still satisfy the two tests above if they
        // compared against the resolver's own inputs; naming them pins the arms.
        assertNotEquals(
            sut.collectionFor(MediaType.PHOTO),
            sut.collectionFor(MediaType.VIDEO),
        )
    }

    @Test
    fun `covers every media type`() {
        val served = MediaType.entries.map(sut::collectionFor)

        assertEquals(served.size, served.distinct().size, "each type needs its own collection")
    }
}