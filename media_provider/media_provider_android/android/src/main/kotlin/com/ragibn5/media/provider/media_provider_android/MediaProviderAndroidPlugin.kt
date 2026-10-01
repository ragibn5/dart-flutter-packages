package com.ragibn5.media.provider.media_provider_android

import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.handlers.GetMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

public class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext

        attach(
            flutterPluginBinding.binaryMessenger,
            MediaStoreServiceFactory.create(appContext),
        )
    }

    /**
     * Serves [mediaStoreService] over [binaryMessenger].
     *
     * Separate from [onAttachedToEngine] so the wiring can be exercised without
     * a device: building the real service reads `MediaStore`, which only exists
     * on Android.
     */
    @VisibleForTesting
    internal fun attach(binaryMessenger: BinaryMessenger, mediaStoreService: MediaStoreService) {
        requestDispatcher = MethodCallDispatcher(
            listOf(
                GetMediaRequestHandler(mediaStoreService),
            ),
        )
        channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        requestDispatcher.dispose()
    }

    private companion object {
        private const val CHANNEL_NAME = "media_provider"
    }
}
