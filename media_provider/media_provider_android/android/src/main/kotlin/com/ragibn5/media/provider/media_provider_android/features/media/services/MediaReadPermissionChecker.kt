package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

/**
 * Tells whether the app may read media at all.
 */
internal fun interface MediaReadPermissionChecker {
    /**
     * @return `true` if any media read permission is granted.
     *
     * Note: Doesn't tell whether a given item can be read; with only photos,
     * only videos, or only some items granted, reading the others still fails.
     */
    fun isGranted(): Boolean
}

internal class MediaReadPermissionCheckerImpl(
    private val context: Context,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) : MediaReadPermissionChecker {
    override fun isGranted(): Boolean {
        return buildPermissions().any { permission ->
            ContextCompat.checkSelfPermission(context, permission) ==
                PackageManager.PERMISSION_GRANTED
        }
    }

    /**
     * The permissions that let the app read media on this Android version.
     */
    private fun buildPermissions(): List<String> {
        return when {
            sdkInt >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE -> listOf(
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO,
                // Access to only the items the user picked.
                Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED,
            )

            sdkInt >= Build.VERSION_CODES.TIRAMISU -> listOf(
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO,
            )

            else -> listOf(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
    }
}
