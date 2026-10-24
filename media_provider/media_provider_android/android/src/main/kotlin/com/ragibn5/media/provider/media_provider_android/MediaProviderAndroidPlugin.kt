package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaStoreServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.BackgroundReadCallHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.CloseReadSessionRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.OpenMediaReadRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.QueryMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.ReadMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.features.volume.di.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.volume.handlers.GetVolumesHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

public class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var readChannel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher
    private lateinit var mediaStoreService: MediaStoreService

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
        // One instance, so getVolumes and the media feature see the same volumes.
        val volumeProviderService = VolumeProviderServiceFactory.create(appContext)
        mediaStoreService = MediaStoreServiceFactory.create(appContext, volumeProviderService)
        requestDispatcher = MethodCallDispatcher(
            listOf(
                QueryMediaRequestHandler(mediaStoreService),
                OpenMediaReadRequestHandler(mediaStoreService),
                ReadMediaRequestHandler(mediaStoreService),
                CloseReadSessionRequestHandler(mediaStoreService),
                GetVolumesHandler(volumeProviderService),
            ),
        )
        channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }

        // Experimental: reads on a background task queue, off the main thread.
        readChannel = MethodChannel(
            binaryMessenger,
            READ_CHANNEL_NAME,
            StandardMethodCodec.INSTANCE,
            binaryMessenger.makeBackgroundTaskQueue(),
        ).apply { setMethodCallHandler(BackgroundReadCallHandler(mediaStoreService)) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        readChannel.setMethodCallHandler(null)
        requestDispatcher.dispose()
    }

    private companion object {
        private const val CHANNEL_NAME = "media_provider_android"
        private const val READ_CHANNEL_NAME = "media_provider_android/read"
    }
}
