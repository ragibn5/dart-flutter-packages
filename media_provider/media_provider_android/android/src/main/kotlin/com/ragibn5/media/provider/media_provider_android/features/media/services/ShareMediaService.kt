package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaMimeTypeResolver.Companion.ANY_MIME_TYPE

/**
 * Shares `MediaStore` items with other apps, through the system share sheet.
 */
internal fun interface ShareMediaService {
    /**
     * Shows the system share sheet for the items [request] points to.
     *
     * @param request the items to share, and the chooser's title.
     * @throws MediaProviderException with a [MediaActionExceptionCodes] code.
     */
    fun share(request: ShareMediaRequest)
}

internal class ShareMediaServiceImpl(
    private val chooserLauncher: MediaChooserLauncher,
    private val mimeTypeResolver: MediaMimeTypeResolver,
) : ShareMediaService {
    override fun share(request: ShareMediaRequest) {
        val uris = request.contentUris.map { it.toUri() }

        val intent = if (uris.size == 1) {
            Intent(Intent.ACTION_SEND)
                .putExtra(Intent.EXTRA_STREAM, uris.single())
        } else {
            Intent(Intent.ACTION_SEND_MULTIPLE)
                .putParcelableArrayListExtra(Intent.EXTRA_STREAM, ArrayList(uris))
        }
        intent.type = resolveSharedMimeType(uris)
        intent.clipData = buildClipData(uris)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        chooserLauncher.launch(intent, request.chooserTitle)
    }

    /**
     * The MIME type to share [uris] as: their exact type when they all have
     * the same one, a wildcard subtype (such as `image/` with `*`) when they
     * only share the top-level type, and any type otherwise.
     */
    private fun resolveSharedMimeType(uris: List<Uri>): String {
        val mimeTypes = uris.map { mimeTypeResolver.resolve(it) ?: ANY_MIME_TYPE }.distinct()
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
     * The clip data for [uris]; the read grant covers the URIs in it, so every
     * item is readable by the app it's shared with.
     */
    private fun buildClipData(uris: List<Uri>): ClipData {
        return ClipData.newRawUri(null, uris.first()).apply {
            uris.drop(1).forEach { addItem(ClipData.Item(it)) }
        }
    }
}
