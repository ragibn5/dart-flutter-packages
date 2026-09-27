package com.ragibn5.media.provider.media_provider_android.handlers

import com.ragibn5.media.provider.media_provider_android.services.MediaStoreService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.serialization.json.Json

/**
 * Replies with all photos, encoded as a JSON array of `MediaItemData`.
 */
class GetPhotosRequestHandler(
    private val mediaStoreService: MediaStoreService,
) : MethodCallRequestHandler {
    override val method = "getPhotos"

    override fun handle(call: MethodCall, result: Result) {
        val photos = mediaStoreService.getPhotos()
        result.success(Json.encodeToString(photos))
    }
}
