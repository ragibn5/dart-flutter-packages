package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.handlers.GetMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreCollectionRegistry
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceFactory
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceImpl
import com.ragibn5.media.provider.media_provider_android.services.PhotoMediaStoreCollection
import com.ragibn5.media.provider.media_provider_android.services.VideoMediaStoreCollection
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

public class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext
        val mediaStoreService = MediaStoreServiceFactory.create(appContext.contentResolver)

        requestDispatcher = MethodCallDispatcher(
            listOf(
                GetMediaRequestHandler(mediaStoreService),
            ),
        )
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
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