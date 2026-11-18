package com.ragibn5.media.provider.media_provider_android

import android.app.Activity
import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.media.provider.media_provider_android.features.media.di.MediaQueryServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.di.OpenMediaWithServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.di.ShareMediaServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.OpenMediaWithRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.QueryMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.handlers.ShareMediaRequestHandler
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaQueryService
import com.ragibn5.media.provider.media_provider_android.features.media.services.OpenMediaWithService
import com.ragibn5.media.provider.media_provider_android.features.media.services.ShareMediaService
import com.ragibn5.media.provider.media_provider_android.features.volume.di.VolumeProviderServiceFactory
import com.ragibn5.media.provider.media_provider_android.features.volume.handlers.GetVolumesHandler
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumeProviderService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

public class MediaProviderAndroidPlugin : FlutterPlugin, ActivityAware {
    private lateinit var mainChannel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher
    private lateinit var mediaQueryService: MediaQueryService
    private lateinit var volumeProviderService: VolumeProviderService
    private lateinit var shareMediaService: ShareMediaService
    private lateinit var openMediaWithService: OpenMediaWithService

    /** The activity to start choosers from, while one is attached. */
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val appContext = flutterPluginBinding.applicationContext
        attach(
            appContext,
            flutterPluginBinding.binaryMessenger,
        )
    }

    /**
     * Serves [mediaQueryService], [shareMediaService], [openMediaWithService]
     * and [volumeProviderService] over [binaryMessenger].
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
        shareMediaService = ShareMediaServiceFactory.create(appContext) { activity }
        openMediaWithService = OpenMediaWithServiceFactory.create(appContext) { activity }

        // Main request dispatcher
        requestDispatcher = MethodCallDispatcher(
            listOf(
                QueryMediaRequestHandler(mediaQueryService),
                ShareMediaRequestHandler(shareMediaService),
                OpenMediaWithRequestHandler(openMediaWithService),
                GetVolumesHandler(volumeProviderService),
            ),
        )

        // Channels
        mainChannel = MethodChannel(binaryMessenger, MAIN_CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Close the channels
        mainChannel.setMethodCallHandler(null)

        // Close the main dispatcher
        requestDispatcher.dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private companion object {
        private const val MAIN_CHANNEL_NAME = "media_provider_android"
    }
}
