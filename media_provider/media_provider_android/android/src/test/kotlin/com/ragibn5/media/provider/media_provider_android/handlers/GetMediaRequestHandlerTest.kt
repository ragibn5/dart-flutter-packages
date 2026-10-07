package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.photoItem
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.videoItem
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
internal class GetMediaRequestHandlerTest {
    private val service = FakeMediaStoreService()
    private val handler = GetMediaRequestHandler(service, UnconfinedTestDispatcher())

    private fun callWithTypes(vararg types: Any?) =
        MethodCall("getMedia", mapOf("types" to types.toList()))

    private companion object {
        /** What the Dart side sends for `AndroidMediaType.photo`. */
        const val PHOTO = "PHOTO"

        /** What the Dart side sends for `AndroidMediaType.video`. */
        const val VIDEO = "VIDEO"

        /** A name matching no `MediaType` entry. */
        const val UNKNOWN = "AUDIO"
    }

    @Test
    fun `replies with the service's media encoded as JSON`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(callWithTypes(PHOTO, VIDEO)),
        )
    }

    @Test
    fun `encodes media types by their wire name, not their enum name`() = runTest {
        service.items = listOf(photoItem())

        val reply = handler.handle(callWithTypes(PHOTO)) as String

        assertTrue(reply.contains("\"type\":\"$PHOTO\""), reply)
        assertTrue(!reply.contains("photo"), reply)
    }

    @Test
    fun `replies with media the caller can decode back`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        val reply = handler.handle(callWithTypes(PHOTO, VIDEO)) as String

        assertEquals(service.items, Json.decodeFromString<List<MediaItem>>(reply))
    }

    @Test
    fun `replies with the volume nested under its own key`() = runTest {
        service.items = listOf(photoItem())

        val reply = handler.handle(callWithTypes(PHOTO)) as String

        // The Dart side reads this key, so the shape is pinned here rather than
        // left to whatever a round trip happens to agree with.
        assertTrue(reply.contains("\"volumeInfo\":{\"isPrimary\":true,\"uuid\":null}"), reply)
        assertTrue(!reply.contains("volumeName"), reply)
    }

    @Test
    fun `replies with an empty JSON array when the library is empty`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(callWithTypes(PHOTO)))
    }

    @Test
    fun `queries the service with every requested type`() = runTest {
        handler.handle(callWithTypes(PHOTO, VIDEO))

        assertEquals(setOf(MediaType.PHOTO, MediaType.VIDEO), service.requestedTypes)
    }

    @Test
    fun `queries the service once per distinct type`() = runTest {
        handler.handle(callWithTypes(PHOTO, VIDEO, PHOTO))

        assertEquals(setOf(MediaType.PHOTO, MediaType.VIDEO), service.requestedTypes)
    }

    @Test
    fun `rejects a missing 'types' argument`() = runTest {
        val error =
            assertFailsWith<MethodCallException> { handler.handle(MethodCall("getMedia", null)) }

        assertEquals("invalid_argument", error.code)
        assertEquals("'types' must be a list", error.message)
    }

    @Test
    fun `rejects a 'types' argument that is not a list`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(MethodCall("getMedia", mapOf("types" to "photo")))
        }

        assertEquals("invalid_argument", error.code)
        assertEquals("'types' must be a list", error.message)
    }

    @Test
    fun `rejects an empty 'types' argument`() = runTest {
        val error = assertFailsWith<MethodCallException> { handler.handle(callWithTypes()) }

        assertEquals("invalid_argument", error.code)
        assertEquals("'types' must not be empty", error.message)
    }

    @Test
    fun `rejects a non-string entry in 'types'`() = runTest {
        val error =
            assertFailsWith<MethodCallException> { handler.handle(callWithTypes(PHOTO, 1)) }

        assertEquals("invalid_argument", error.code)
        assertEquals("Unknown media type: 1", error.message)
    }

    @Test
    fun `rejects an unknown media type name`() = runTest {
        val error = assertFailsWith<MethodCallException> { handler.handle(callWithTypes(UNKNOWN)) }

        assertEquals("invalid_argument", error.code)
        assertEquals("Unknown media type: $UNKNOWN", error.message)
    }

    @Test
    fun `keeps the serialization failure that caused a rejected media type`() = runTest {
        val error = assertFailsWith<MethodCallException> { handler.handle(callWithTypes(UNKNOWN)) }

        assertTrue(error.cause is SerializationException, "${error.cause}")
    }

    @Test
    fun `does not query the service when the arguments are invalid`() = runTest {
        assertFailsWith<MethodCallException> { handler.handle(callWithTypes(UNKNOWN)) }

        assertNull(service.requestedTypes)
    }

    private class FakeMediaStoreService : MediaStoreService {
        var items: List<MediaItem> = emptyList()
        var requestedTypes: Set<MediaType>? = null

        override suspend fun getMedia(types: Set<MediaType>): List<MediaItem> {
            requestedTypes = types
            return items
        }
    }
}
