package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * [MediaProviderAndroidPlugin] owns the channel name and the attach/detach
 * lifecycle. These tests drive those two concerns through [attach], which takes
 * the service as an argument, so no part of this depends on `MediaStore` or on
 * a device context.
 */
@OptIn(ExperimentalCoroutinesApi::class)
internal class MediaProviderAndroidPluginTest {
    private val messenger = FakeBinaryMessenger()
    private val service = FakeMediaStoreService()
    private val plugin = MediaProviderAndroidPlugin()

    @BeforeEach
    fun installMainDispatcher() {
        // The dispatcher the plugin builds replies on `Dispatchers.Main`.
        Dispatchers.setMain(UnconfinedTestDispatcher())
    }

    @AfterEach
    fun removeMainDispatcher() {
        Dispatchers.resetMain()
    }

    private fun attach() = plugin.attach(messenger, service)

    @Test
    fun `registers a handler on its own channel`() {
        attach()

        assertNotNull(messenger.handlers[CHANNEL], "expected a handler on '$CHANNEL'")
    }

    @Test
    fun `registers on exactly one channel`() {
        attach()

        assertEquals(listOf(CHANNEL), messenger.handlers.keys.toList())
    }

    @Test
    fun `clears the channel handler when detached`() {
        attach()

        plugin.onDetachedFromEngine(detachBinding())

        assertNull(messenger.handlers[CHANNEL], "the handler must be cleared on detach")
    }

    @Test
    fun `replies not implemented for a method it does not serve`() {
        attach()

        val reply = messenger.dispatch(CHANNEL, MethodCall("nope", null))

        assertNull(reply, "an unknown method must be answered with notImplemented")
    }

    @Test
    fun `rejects getMedia with invalid arguments instead of querying`() {
        attach()

        val error = messenger.decodeError(
            messenger.dispatch(
                CHANNEL,
                MethodCall("getMedia", mapOf("types" to emptyList<String>()))
            ),
        )

        assertEquals("invalid_argument", error.code)
        assertEquals("'types' must not be empty", error.message)
        assertNull(service.requestedTypes, "the service must not be queried")
    }

    @Test
    fun `stops serving after being detached`() {
        attach()
        plugin.onDetachedFromEngine(detachBinding())

        val error = runCatching { messenger.dispatch(CHANNEL, getMediaCall(listOf("photo"))) }

        assertTrue(error.isFailure, "the channel should no longer be served")
    }

    @Test
    fun `attaching again replaces the handler rather than adding one`() {
        attach()
        attach()

        assertEquals(listOf(CHANNEL), messenger.handlers.keys.toList())
    }

    private fun detachBinding() = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)

    private class FakeMediaStoreService : MediaStoreService {
        var items: List<MediaItem> = emptyList()
        var requestedTypes: Set<MediaType>? = null

        override suspend fun getMedia(types: Set<MediaType>): List<MediaItem> {
            requestedTypes = types
            return items
        }
    }

    private companion object {
        /** Mirrors the plugin's private channel name. */
        const val CHANNEL = "media_provider"
    }
}
