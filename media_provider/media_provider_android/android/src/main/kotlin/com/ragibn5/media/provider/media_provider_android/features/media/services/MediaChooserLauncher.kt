package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.app.Activity
import android.content.Intent
import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes

/**
 * Starts the system chooser from the current activity.
 */
internal class MediaChooserLauncher(
    private val currentActivity: () -> Activity?,
) {
    /**
     * Starts the system chooser for [intent].
     *
     * @param intent the intent to choose an app for.
     * @param title the chooser's title, or `null` for the system's default.
     * @throws MediaProviderException with
     * [MediaActionExceptionCodes.NO_ACTIVITY] if no activity is attached, or
     * [MediaActionExceptionCodes.PERMISSION_DENIED] if the app may not grant
     * access to the items.
     */
    fun launch(intent: Intent, title: String?) {
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
}
