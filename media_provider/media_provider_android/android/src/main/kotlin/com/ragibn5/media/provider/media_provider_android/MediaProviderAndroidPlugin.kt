package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import com.ragibn5.media.provider.media_provider_android.services.MediaStoreServiceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.serialization.json.Json

class MediaProviderAndroidPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "media_provider"
        const val GET_PHOTOS_METHOD_NAME = "getPhotos"
    }

    private lateinit var appContext: Context
    private lateinit var channel: MethodChannel
    private lateinit var mediaStoreService: MediaStoreService

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        mediaStoreService = MediaStoreServiceFactory.create(appContext.contentResolver)

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            GET_PHOTOS_METHOD_NAME -> handleGetPhotosRequest(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun handleGetPhotosRequest(result: Result) {
        val photos = mediaStoreService.getPhotos()
        result.success(Json.encodeToString(photos))
    }
}
