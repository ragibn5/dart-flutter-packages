package com.ragibn5.user.provider.user_provider_android

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
 * [UserProviderAndroidPlugin] owns the channel name and the attach/detach
 * lifecycle. These tests drive those two concerns through [attach], so no part
 * of this depends on `Process` or on a device.
 */
@OptIn(ExperimentalCoroutinesApi::class)
internal class UserProviderAndroidPluginTest {
    private val messenger = FakeBinaryMessenger()
    private val plugin = UserProviderAndroidPlugin()

    @BeforeEach
    fun installMainDispatcher() {
        // The dispatcher the plugin builds replies on `Dispatchers.Main`.
        Dispatchers.setMain(UnconfinedTestDispatcher())
    }

    @AfterEach
    fun removeMainDispatcher() {
        Dispatchers.resetMain()
    }

    private fun attach() = plugin.attach(messenger)

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
    fun `serves getIdentity`() {
        attach()

        val reply = messenger.dispatch(CHANNEL, getIdentityCall())

        assertNotNull(reply, "getIdentity must be served, not answered notImplemented")
    }

    @Test
    fun `stops serving after being detached`() {
        attach()
        plugin.onDetachedFromEngine(detachBinding())

        val error = runCatching { messenger.dispatch(CHANNEL, getIdentityCall()) }

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
        const val CHANNEL = "user_provider_android"
    }
}