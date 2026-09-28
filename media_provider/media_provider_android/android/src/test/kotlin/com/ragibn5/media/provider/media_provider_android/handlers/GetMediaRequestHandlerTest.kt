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

    @Test
    fun `replies with the service's media encoded as JSON`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(callWithTypes("photo", "video")),
        )
    }

    @Test
    fun `encodes media types by their wire name, not their enum name`() = runTest {
        service.items = listOf(photoItem())

        val reply = handler.handle(callWithTypes("photo")) as String

        assertTrue(reply.contains("\"type\":\"photo\""), reply)
        assertTrue(!reply.contains("PHOTO"), reply)
    }

    @Test
    fun `replies with media the caller can decode back`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        val reply = handler.handle(callWithTypes("photo", "video")) as String

        assertEquals(service.items, Json.decodeFromString<List<MediaItem>>(reply))
    }

    @Test
    fun `replies with an empty JSON array when the library is empty`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(callWithTypes("photo")))
    }

    @Test
    fun `queries the service with every requested type`() = runTest {
        handler.handle(callWithTypes("photo", "video"))

        assertEquals(setOf(MediaType.PHOTO, MediaType.VIDEO), service.requestedTypes)
    }

    @Test
    fun `queries the service once per distinct type`() = runTest {
        handler.handle(callWithTypes("photo", "video", "photo"))

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
            assertFailsWith<MethodCallException> { handler.handle(callWithTypes("photo", 1)) }

        assertEquals("invalid_argument", error.code)
        assertEquals("Unknown media type: 1", error.message)
    }

    @Test
    fun `rejects an unknown media type name`() = runTest {
        val error = assertFailsWith<MethodCallException> { handler.handle(callWithTypes("audio")) }

        assertEquals("invalid_argument", error.code)
        assertEquals("Unknown media type: audio", error.message)
    }

    @Test
    fun `keeps the serialization failure that caused a rejected media type`() = runTest {
        val error = assertFailsWith<MethodCallException> { handler.handle(callWithTypes("audio")) }

        assertTrue(error.cause is SerializationException, "${error.cause}")
    }

    @Test
    fun `does not query the service when the arguments are invalid`() = runTest {
        assertFailsWith<MethodCallException> { handler.handle(callWithTypes("audio")) }

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
