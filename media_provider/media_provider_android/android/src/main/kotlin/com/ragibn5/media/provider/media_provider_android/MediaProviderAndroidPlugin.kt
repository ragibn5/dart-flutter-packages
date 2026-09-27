package com.ragibn5.media.provider.media_provider_android

import com.ragibn5.media.provider.media_provider_android.handlers.GetPhotosRequestHandler
import com.ragibn5.media.provider.media_provider_android.handlers.MethodCallDispatcher
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext
        val mediaStoreService = MediaStoreServiceFactory.create(appContext.contentResolver)
        val requestDispatcher = MethodCallDispatcher(
            listOf(
                GetPhotosRequestHandler(mediaStoreService),
            ),
        )

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val CHANNEL_NAME = "media_provider"
    }
}
