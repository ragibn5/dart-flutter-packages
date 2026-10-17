package com.ragibn5.user.provider.user_provider_android

import androidx.annotation.VisibleForTesting
import com.ragibn5.user.provider.user_provider_android.handlers.GetIdentityHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

public class UserProviderAndroidPlugin : FlutterPlugin {
    private lateinit var channel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        attach(flutterPluginBinding.binaryMessenger)
    }

    /**
     * Serves [binaryMessenger] on this plugin's channel.
     *
     * Separate from [onAttachedToEngine] so the wiring can be exercised without
     * a device.
     */
    @VisibleForTesting
    internal fun attach(binaryMessenger: BinaryMessenger) {
        requestDispatcher = MethodCallDispatcher(
            listOf(
                GetIdentityHandler(),
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
        private const val CHANNEL_NAME = "user_provider_android"
    }
}