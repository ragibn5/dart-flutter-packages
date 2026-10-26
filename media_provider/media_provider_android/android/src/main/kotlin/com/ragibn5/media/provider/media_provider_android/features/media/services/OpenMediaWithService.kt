package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.Intent
import androidx.core.net.toUri
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaMimeTypeResolver.Companion.ANY_MIME_TYPE

/**
 * Opens `MediaStore` items in other apps, picked from the system chooser.
 */
internal interface OpenMediaWithService {
    /**
     * Shows the apps that can open the item [request] points to.
     *
     * @param request the item to open, and the chooser's title.
     * @throws MediaProviderException with a [MediaActionExceptionCodes] code.
     */
    fun openWith(request: OpenMediaWithRequest)
}

internal class OpenMediaWithServiceImpl(
    private val chooserLauncher: MediaChooserLauncher,
    private val mimeTypeResolver: MediaMimeTypeResolver,
) : OpenMediaWithService {
    override fun openWith(request: OpenMediaWithRequest) {
        val uri = request.contentUri.toUri()
        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, mimeTypeResolver.resolve(uri) ?: ANY_MIME_TYPE)
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

        chooserLauncher.launch(intent, request.chooserTitle)
    }
}
