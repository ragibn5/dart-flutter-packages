package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.app.Activity
import android.content.ClipData
import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest

/**
 * Hands `MediaStore` items to other apps, through the system chooser.
 */
internal interface MediaActionService {
    /**
     * Shows the system share sheet for the items [request] points to.
     *
     * @param request the items to share, and the chooser's title.
     * @throws MediaProviderException with a [MediaActionExceptionCodes] code.
     */
    fun share(request: ShareMediaRequest)
}

internal class MediaActionServiceImpl(
    private val contentResolver: ContentResolver,
    private val currentActivity: () -> Activity?,
) : MediaActionService {
    override fun share(request: ShareMediaRequest) {
        val uris = request.contentUris.map { it.toUri() }
        val intent = if (uris.size == 1) {
            Intent(Intent.ACTION_SEND).putExtra(Intent.EXTRA_STREAM, uris.single())
        } else {
            Intent(Intent.ACTION_SEND_MULTIPLE)
                .putParcelableArrayListExtra(Intent.EXTRA_STREAM, ArrayList(uris))
        }
        intent.type = resolveSharedMimeType(uris)
        // The read grant covers the URIs in the clip data, so every item is
        // readable by the app it's shared with.
        intent.clipData = buildClipData(uris)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startChooser(intent, request.chooserTitle)
    }

    /**
     * Starts the system chooser for [intent] from the current activity.
     *
     * @param intent the intent to choose an app for.
     * @param title the chooser's title, or `null` for the system's default.
     * @throws MediaProviderException with
     * [MediaActionExceptionCodes.NO_ACTIVITY] if no activity is attached, or
     * [MediaActionExceptionCodes.PERMISSION_DENIED] if the app may not grant
     * access to the items.
     */
    private fun startChooser(intent: Intent, title: String?) {
        val activity = currentActivity()
            ?: throw MediaProviderException(
                MediaActionExceptionCodes.NO_ACTIVITY,
                "No activity to show the chooser from; the app must be in the foreground"
            )
        try {
            activity.startActivity(Intent.createChooser(intent, title))
        } catch (e: SecurityException) {
            throw MediaProviderException(
                MediaActionExceptionCodes.PERMISSION_DENIED,
                e.message ?: "Not allowed to share access to the media items",
                cause = e
            )
        }
    }

    /**
     * The MIME type to share [uris] as: their exact type when they all have
     * the same one, a wildcard subtype (such as `image/` with `*`) when they
     * only share the top-level type, and any type otherwise.
     */
    private fun resolveSharedMimeType(uris: List<Uri>): String {
        val mimeTypes = uris.map { resolveMimeType(it) ?: ANY_MIME_TYPE }.distinct()
        if (mimeTypes.size == 1) {
            return mimeTypes.single()
        }

        val topLevelTypes = mimeTypes.map { it.substringBefore('/') }.distinct()
        val topLevelType = topLevelTypes.singleOrNull()
        if (topLevelType == null || topLevelType == "*") {
            return ANY_MIME_TYPE
        }
        return "$topLevelType/*"
    }

    /**
     * The MIME type of the item at [uri], read from its provider.
     *
     * @return the type, or `null` if the provider doesn't know it.
     * @throws MediaProviderException with
     * [MediaActionExceptionCodes.INVALID_REQUEST] if [uri] isn't a valid item
     * URI.
     */
    private fun resolveMimeType(uri: Uri): String? {
        try {
            return contentResolver.getType(uri)
        } catch (e: IllegalArgumentException) {
            throw MediaProviderException(
                MediaActionExceptionCodes.INVALID_REQUEST,
                e.message ?: "The content uri is not a valid media item uri",
                details = mapOf("uri" to uri.toString()),
                cause = e
            )
        }
    }

    private fun buildClipData(uris: List<Uri>): ClipData {
        return ClipData.newRawUri(null, uris.first()).apply {
            uris.drop(1).forEach { addItem(ClipData.Item(it)) }
        }
    }

    private companion object {
        const val ANY_MIME_TYPE = "*/*"
    }
}
