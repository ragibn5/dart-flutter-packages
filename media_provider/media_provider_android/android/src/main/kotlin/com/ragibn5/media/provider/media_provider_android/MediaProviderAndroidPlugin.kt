package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaQueryServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaReadServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.BackgroundReadCallHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.CloseReadSessionRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.OpenMediaReadRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.OpenThumbnailReadRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.QueryMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryService
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaReadService
import com.ragibn5.media.provider.media_provider_android.features.volume.di.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.volume.handlers.GetVolumesHandler
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

public class MediaProviderAndroidPlugin : FlutterPlugin {
    private lateinit var mainChannel: MethodChannel
    private lateinit var readChannel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher
    private lateinit var mediaQueryService: MediaQueryService
    private lateinit var mediaReadService: MediaReadService
    private lateinit var volumeProviderService: VolumeProviderService

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext
        attach(
            appContext,
            flutterPluginBinding.binaryMessenger,
        )
    }

    /**
     * Serves [mediaQueryService], [mediaReadService] and [volumeProviderService]
     * over [binaryMessenger].
     *
     * Separate from [onAttachedToEngine] so the wiring can be exercised without
     * a device: building the real services reads `MediaStore`, which only
     * exists on Android.
     */
    @VisibleForTesting
    internal fun attach(appContext: Context, binaryMessenger: BinaryMessenger) {
        // Services
        volumeProviderService = VolumeProviderServiceFactory.create(appContext)
        mediaQueryService = MediaQueryServiceFactory.create(appContext, volumeProviderService)
        mediaReadService = MediaReadServiceFactory.create(appContext)

        // Main request dispatcher
        requestDispatcher = MethodCallDispatcher(
            listOf(
                QueryMediaRequestHandler(mediaQueryService),
                OpenMediaReadRequestHandler(mediaReadService),
                OpenThumbnailReadRequestHandler(mediaReadService),
                CloseReadSessionRequestHandler(mediaReadService),
                GetVolumesHandler(volumeProviderService),
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
        ).apply { setMethodCallHandler(BackgroundReadCallHandler(mediaReadService)) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Close the channels
        mainChannel.setMethodCallHandler(null)
        readChannel.setMethodCallHandler(null)

        // Close the main dispatcher
        requestDispatcher.dispose()

        // Close the services that needs closing
        mediaReadService.closeAllReadSessions()
    }

    private companion object {
        private const val MAIN_CHANNEL_NAME = "media_provider_android"
        private const val READ_CHANNEL_NAME = "media_provider_android/read"
    }
}
