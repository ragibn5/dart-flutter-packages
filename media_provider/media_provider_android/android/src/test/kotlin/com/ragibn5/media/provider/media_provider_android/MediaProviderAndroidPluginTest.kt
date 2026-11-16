package com.ragibn5.media.provider.media_provider_android

import android.content.ContentResolver
import android.content.Context
import android.os.storage.StorageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import java.nio.ByteBuffer
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
internal class MediaProviderAndroidPluginTest {
    /** A [BinaryMessenger] that records the handler set on each channel, and its task queue. */
    private class FakeBinaryMessenger : BinaryMessenger {
        val handlers = mutableMapOf<String, BinaryMessenger.BinaryMessageHandler?>()
        val taskQueues = mutableMapOf<String, BinaryMessenger.TaskQueue?>()

        override fun makeBackgroundTaskQueue(options: BinaryMessenger.TaskQueueOptions): BinaryMessenger.TaskQueue =
            object : BinaryMessenger.TaskQueue {}

        override fun send(channel: String, message: ByteBuffer?) = Unit

        override fun send(channel: String, message: ByteBuffer?, callback: BinaryMessenger.BinaryReply?) = Unit

        override fun setMessageHandler(channel: String, handler: BinaryMessenger.BinaryMessageHandler?) {
            setMessageHandler(channel, handler, null)
        }

        override fun setMessageHandler(
            channel: String,
            handler: BinaryMessenger.BinaryMessageHandler?,
            taskQueue: BinaryMessenger.TaskQueue?,
        ) {
            handlers[channel] = handler
            taskQueues[channel] = taskQueue
        }
    }

    private val messenger = FakeBinaryMessenger()
    private val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java).also {
        val context = Mockito.mock(Context::class.java)
        Mockito.`when`(context.contentResolver).thenReturn(Mockito.mock(ContentResolver::class.java))
        Mockito.`when`(context.getSystemService(StorageManager::class.java))
            .thenReturn(Mockito.mock(StorageManager::class.java))
        Mockito.`when`(it.applicationContext).thenReturn(context)
        Mockito.`when`(it.binaryMessenger).thenReturn(messenger)
    }
    private val plugin = MediaProviderAndroidPlugin()

    @BeforeEach
    fun setUp() = Dispatchers.setMain(UnconfinedTestDispatcher())

    @AfterEach
    fun tearDown() = Dispatchers.resetMain()

    @Test
    fun onAttachedToEngineShouldServeMainChannel() {
        plugin.onAttachedToEngine(binding)

        assertNotNull(messenger.handlers[MAIN_CHANNEL])
    }

    @Test
    fun onAttachedToEngineShouldServeReadChannelOnBackgroundTaskQueue() {
        plugin.onAttachedToEngine(binding)

        assertNotNull(messenger.handlers[READ_CHANNEL])
        assertNotNull(messenger.taskQueues[READ_CHANNEL])
    }

    @Test
    fun onDetachedFromEngineShouldStopServingBothChannels() {
        plugin.onAttachedToEngine(binding)

        plugin.onDetachedFromEngine(binding)

        assertNull(messenger.handlers[MAIN_CHANNEL])
        assertNull(messenger.handlers[READ_CHANNEL])
    }

    private companion object {
        const val MAIN_CHANNEL = "media_provider_android"
        const val READ_CHANNEL = "media_provider_android/read"
    }
}
