package com.ragibn5.content.io.content_io_android

import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.content.io.content_io_android.features.read.di.ContentReadServiceFactory
import com.ragibn5.content.io.content_io_android.features.read.handlers.BackgroundReadCallHandler
import com.ragibn5.content.io.content_io_android.features.read.handlers.CloseReadSessionRequestHandler
import com.ragibn5.content.io.content_io_android.features.read.handlers.OpenReadRequestHandler
import com.ragibn5.content.io.content_io_android.features.read.handlers.OpenThumbnailReadRequestHandler
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.write.di.ContentWriteServiceFactory
import com.ragibn5.content.io.content_io_android.features.write.handlers.BackgroundWriteCallHandler
import com.ragibn5.content.io.content_io_android.features.write.handlers.OpenWriteRequestHandler
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

public class ContentIoAndroidPlugin : FlutterPlugin {
    private lateinit var mainChannel: MethodChannel
    private lateinit var readChannel: MethodChannel
    private lateinit var writeChannel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher
    private lateinit var contentReadService: ContentReadService
    private lateinit var contentWriteService: ContentWriteService

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext
        attach(
            appContext,
            flutterPluginBinding.binaryMessenger,
        )
    }

    /**
     * Serves [contentReadService] and [contentWriteService] over
     * [binaryMessenger].
     *
     * Separate from [onAttachedToEngine] so the wiring can be exercised without
     * a device: building the real services needs a `ContentResolver`, which
     * only exists on Android.
     */
    @VisibleForTesting
    internal fun attach(appContext: Context, binaryMessenger: BinaryMessenger) {
        // Services
        contentReadService = ContentReadServiceFactory.create(appContext)
        contentWriteService = ContentWriteServiceFactory.create(appContext)

        // Main request dispatcher
        requestDispatcher = MethodCallDispatcher(
            listOf(
                OpenReadRequestHandler(contentReadService),
                OpenThumbnailReadRequestHandler(contentReadService),
                CloseReadSessionRequestHandler(contentReadService),
                OpenWriteRequestHandler(contentWriteService),
            ),
        )

        // Channels
        mainChannel = MethodChannel(binaryMessenger, MAIN_CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }
        readChannel = MethodChannel(
            binaryMessenger,
            READ_CHANNEL_NAME,
            StandardMethodCodec.INSTANCE,
            binaryMessenger.makeBackgroundTaskQueue(),
        ).apply { setMethodCallHandler(BackgroundReadCallHandler(contentReadService)) }
        // A queue of its own, so writing never waits for reading.
        writeChannel = MethodChannel(
            binaryMessenger,
            WRITE_CHANNEL_NAME,
            StandardMethodCodec.INSTANCE,
            binaryMessenger.makeBackgroundTaskQueue(),
        ).apply { setMethodCallHandler(BackgroundWriteCallHandler(contentWriteService)) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Close the channels
        mainChannel.setMethodCallHandler(null)
        readChannel.setMethodCallHandler(null)
        writeChannel.setMethodCallHandler(null)

        // Close the main dispatcher
        requestDispatcher.dispose()

        // Close the services that needs closing
        contentReadService.closeAllReadSessions()
        contentWriteService.abortAllWriteSessions()
    }

    private companion object {
        private const val MAIN_CHANNEL_NAME = "content_io_android"
        private const val READ_CHANNEL_NAME = "content_io_android/read"
        private const val WRITE_CHANNEL_NAME = "content_io_android/write"
    }
}
