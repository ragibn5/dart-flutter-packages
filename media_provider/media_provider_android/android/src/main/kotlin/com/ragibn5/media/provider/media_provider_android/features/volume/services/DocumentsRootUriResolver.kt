package com.ragibn5.media.provider.media_provider_android.features.volume.services

import android.net.Uri
import android.os.Build
import android.os.storage.StorageVolume
import android.provider.DocumentsContract
import androidx.core.content.IntentCompat

/**
 * Resolves a volume's root in the system's documents provider.
 */
internal class DocumentsRootUriResolver(
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    /**
     * The URI of [volume]'s root in the documents provider, such as
     * `content://com.android.externalstorage.documents/root/B63B-1E04`, or
     * `null` when it has none.
     *
     * Note:
     * From Android 10 (API 29) on, it's the platform's own: the folder
     * picker's initial URI for the volume. Below that, it's built the same way.
     */
    fun resolve(volume: StorageVolume): String? {
        if (sdkInt >= Build.VERSION_CODES.Q) {
            val intent = volume.createOpenDocumentTreeIntent()
            return IntentCompat.getParcelableExtra(intent, DocumentsContract.EXTRA_INITIAL_URI, Uri::class.java)
                ?.toString()
        }

        val rootId = if (volume.isPrimary) PRIMARY_ROOT_ID else volume.uuid ?: return null
        return DocumentsContract.buildRootUri(EXTERNAL_STORAGE_AUTHORITY, rootId).toString()
    }

    private companion object {
        private const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"
        private const val PRIMARY_ROOT_ID = "primary"
    }
}
