package com.ragibn5.media.provider.media_provider_android

import android.content.ContentResolver
import android.content.Context
import android.os.storage.StorageManager
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
 * lifecycle. These tests drive those two concerns through [attach], which builds
 * the real services over a mocked context, so no part of this depends on
 * `MediaStore` or on a device.
 */
@OptIn(ExperimentalCoroutinesApi::class)
internal class MediaProviderAndroidPluginTest {
    private val messenger = FakeBinaryMessenger()
    private val storageManager: StorageManager = Mockito.mock(StorageManager::class.java)

    /**
     * A context that answers the one lookup the factories make.
     *
     * Nothing is queried through it: every call below is either rejected before
     * the service is reached or answered `notImplemented`.
     */
    private val context: Context = Mockito.mock(Context::class.java).apply {
        Mockito.`when`(getSystemService(StorageManager::class.java)).thenReturn(storageManager)
        Mockito.`when`(contentResolver)
            .thenReturn(Mockito.mock(ContentResolver::class.java))
    }

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

    private fun attach() = plugin.attach(context, messenger)

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
    fun `serves getMedia`() {
        attach()

        // Rejected on its arguments, but served: the reply is a decoded error
        // rather than the null `notImplemented` sends.
        val error = messenger.decodeError(
            messenger.dispatch(CHANNEL, MethodCall("getMedia", mapOf("query" to "{}"))),
        )

        assertEquals("invalid_argument", error.code)
    }

    @Test
    fun `serves getVolumes`() {
        attach()

        val reply = messenger.dispatch(CHANNEL, getVolumesCall())

        assertNotNull(reply, "getVolumes must be served, not answered notImplemented")
    }

    @Test
    fun `stops serving after being detached`() {
        attach()
        plugin.onDetachedFromEngine(detachBinding())

        val error = runCatching { messenger.dispatch(CHANNEL, getVolumesCall()) }

        assertTrue(error.isFailure, "the channel should no longer be served")
    }

    @Test
    fun `attaching again replaces the handler rather than adding one`() {
        attach()
        attach()

        assertEquals(listOf(CHANNEL), messenger.handlers.keys.toList())
    }

    private fun detachBinding() = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)

    private companion object {
        /** Mirrors the plugin's private channel name. */
        const val CHANNEL = "media_provider_android"
    }
}