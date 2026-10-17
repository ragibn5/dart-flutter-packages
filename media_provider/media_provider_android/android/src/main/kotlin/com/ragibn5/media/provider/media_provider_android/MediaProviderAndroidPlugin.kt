package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.handlers.GetMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.handlers.GetVolumesHandler
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceFactory
import com.ragibn5.media.provider.media_provider_android.services.VolumeProviderServiceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

public class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext

        attach(
            appContext,
            flutterPluginBinding.binaryMessenger,
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
    internal fun attach(appContext: Context, binaryMessenger: BinaryMessenger) {
        requestDispatcher = MethodCallDispatcher(
            listOf(
                GetMediaRequestHandler(MediaStoreServiceFactory.create(appContext)),
                GetVolumesHandler(VolumeProviderServiceFactory.create(appContext)),
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
        private const val CHANNEL_NAME = "media_provider_android"
    }
}
