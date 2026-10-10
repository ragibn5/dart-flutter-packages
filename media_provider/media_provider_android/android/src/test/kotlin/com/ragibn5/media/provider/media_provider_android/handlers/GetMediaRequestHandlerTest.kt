package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.exceptions.MethodCallException
import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.models.VolumeSpec
import com.ragibn5.media.provider.media_provider_android.photoItem
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.videoItem
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
internal class GetMediaRequestHandlerTest {
    private val service = FakeMediaStoreService()
    private val handler = GetMediaRequestHandler(
        mediaStoreService = service,
        dispatcher = UnconfinedTestDispatcher(),
    )

    /**
     * A `getMedia` call shaped the way the Dart side sends it: the whole spec
     * JSON-encoded under `"query"`.
     *
     * The JSON is spelled out rather than encoded from a [QuerySpec] so a test
     * can send a spec the model itself would refuse to build, which is exactly
     * what the rejection tests need.
     */
    private fun callWith(
        types: List<String> = listOf(PHOTO),
        volumes: List<String> = listOf(PRIMARY),
        query: String? = null,
    ) = MethodCall("getMedia", mapOf("query" to (query ?: queryJson(types, volumes))))

    private fun queryJson(types: List<String>, volumes: List<String>) =
        """{"types":[${types.joinToString(",") { "\"$it\"" }}],""" +
                """"volumes":[${volumes.joinToString(",")}]}"""

    private companion object {
        /** What the Dart side sends for `MediaType.photo`. */
        const val PHOTO = "PHOTO"

        /** What the Dart side sends for `MediaType.video`. */
        const val VIDEO = "VIDEO"

        /** A name matching no `MediaType` entry. */
        const val UNKNOWN = "AUDIO"

        /** The primary volume, as the Dart side spells it. */
        const val PRIMARY = """{"type":"primary"}"""

        /** A secondary volume, as the Dart side spells it. */
        fun external(uuid: String) = """{"type":"external","uuid":"$uuid"}"""
    }

    @Test
    fun `replies with the service's media encoded as JSON`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        assertEquals(
            Json.encodeToString(service.items),
            handler.handle(callWith(listOf(PHOTO, VIDEO))),
        )
    }

    @Test
    fun `encodes media types by their wire name, not their enum name`() = runTest {
        service.items = listOf(photoItem())

        val reply = handler.handle(callWith()) as String

        assertTrue(reply.contains("\"type\":\"$PHOTO\""), reply)
        assertTrue(!reply.contains("photo"), reply)
    }

    @Test
    fun `replies with media the caller can decode back`() = runTest {
        service.items = listOf(photoItem(), videoItem())

        val reply = handler.handle(callWith(listOf(PHOTO, VIDEO))) as String

        assertEquals(service.items, Json.decodeFromString<List<MediaItem>>(reply))
    }

    @Test
    fun `replies with the volume nested under its own key`() = runTest {
        service.items = listOf(photoItem())

        val reply = handler.handle(callWith()) as String

        // The Dart side reads this key, so the shape is pinned here rather than
        // left to whatever a round trip happens to agree with.
        assertTrue(reply.contains("\"volumeInfo\":{\"isPrimary\":true,\"uuid\":null}"), reply)
        assertTrue(!reply.contains("volumeName"), reply)
    }

    @Test
    fun `replies with an empty JSON array when the library is empty`() = runTest {
        service.items = emptyList()

        assertEquals("[]", handler.handle(callWith()))
    }

    @Test
    fun `queries the service with every requested type and volume`() = runTest {
        handler.handle(
            callWith(
                types = listOf(PHOTO, VIDEO),
                volumes = listOf(PRIMARY, external("1234-5678")),
            ),
        )

        assertEquals(setOf(MediaType.PHOTO, MediaType.VIDEO), service.requestedSpec?.types)
        assertEquals(
            setOf(VolumeSpec.Primary, VolumeSpec.External("1234-5678")),
            service.requestedSpec?.volumes,
        )
    }

    @Test
    fun `queries the service once per distinct type`() = runTest {
        handler.handle(callWith(types = listOf(PHOTO, VIDEO, PHOTO)))

        assertEquals(setOf(MediaType.PHOTO, MediaType.VIDEO), service.requestedSpec?.types)
    }

    @Test
    fun `rejects a missing 'query' argument`() = runTest {
        val error =
            assertFailsWith<MethodCallException> { handler.handle(MethodCall("getMedia", null)) }

        assertEquals("invalid_argument", error.code)
        assertNotNull(error.message)
    }

    @Test
    fun `rejects a malformed 'query' argument`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(MethodCall("getMedia", mapOf("query" to "{not json")))
        }

        assertEquals("invalid_argument", error.code)
        assertNotNull(error.cause, "the decoding failure must be kept as the cause")
    }

    @Test
    fun `rejects an empty 'types' argument`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(callWith(types = emptyList()))
        }

        assertEquals("invalid_argument", error.code)
        assertEquals("'types' must not be empty", error.message)
    }

    @Test
    fun `rejects an empty 'volumes' argument`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(callWith(volumes = emptyList()))
        }

        assertEquals("invalid_argument", error.code)
        assertEquals("'volumes' must not be empty", error.message)
    }

    @Test
    fun `rejects an unknown media type name`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(callWith(types = listOf(UNKNOWN)))
        }

        assertEquals("invalid_argument", error.code)
    }

    @Test
    fun `rejects an unknown volume discriminator`() = runTest {
        val error = assertFailsWith<MethodCallException> {
            handler.handle(callWith(volumes = listOf("""{"type":"removable"}""")))
        }

        assertEquals("invalid_argument", error.code)
    }

    @Test
    fun `does not query the service when the arguments are invalid`() = runTest {
        assertFailsWith<MethodCallException> { handler.handle(callWith(types = listOf(UNKNOWN))) }

        assertNull(service.requestedSpec)
    }

    private class FakeMediaStoreService : MediaStoreService {
        var items: List<MediaItem> = emptyList()
        var requestedSpec: QuerySpec? = null

        override suspend fun getMedia(spec: QuerySpec): List<MediaItem> {
            requestedSpec = spec
            return items
        }
    }

}