package com.ragibn5.media.provider.media_provider_android.services

import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollectionRegistry
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertSame

/**
 * [com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollectionRegistry] is a one-lookup map from media type to
 * collection, so these tests cover only its lookup and its duplicate guard.
 */
internal class MediaStoreCollectionRegistryTest {
    private val photo = FakeCollection(MediaType.PHOTO)
    private val video = FakeCollection(MediaType.VIDEO)

    @Test
    fun `returns the collection registered for a type`() {
        val registry = MediaStoreCollectionRegistry(setOf(photo, video))

        assertSame(photo, registry.get(MediaType.PHOTO))
        assertSame(video, registry.get(MediaType.VIDEO))
    }

    @Test
    fun `fails for a type that is not registered`() {
        val registry = MediaStoreCollectionRegistry(setOf(photo))

        assertFailsWith<NoSuchElementException> { registry.get(MediaType.VIDEO) }
    }

    @Test
    fun `rejects two collections for the same type`() {
        val error = assertFailsWith<IllegalArgumentException> {
            MediaStoreCollectionRegistry(
                setOf(photo, FakeCollection(MediaType.PHOTO)),
            )
        }

        assertEquals(
            "Multiple MediaStore collections are registered for the same MediaType.",
            error.message,
        )
    }

    @Test
    fun `an empty registry serves no types`() {
        val registry = MediaStoreCollectionRegistry(emptySet())

        assertFailsWith<NoSuchElementException> { registry.get(MediaType.PHOTO) }
    }
}
