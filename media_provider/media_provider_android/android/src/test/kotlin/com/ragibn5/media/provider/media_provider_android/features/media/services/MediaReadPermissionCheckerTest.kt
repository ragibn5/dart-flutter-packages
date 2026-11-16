package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class MediaReadPermissionCheckerTest {
    private val context = Mockito.mock(Context::class.java).also {
        Mockito.`when`(it.checkPermission(Mockito.anyString(), Mockito.anyInt(), Mockito.anyInt()))
            .thenReturn(PackageManager.PERMISSION_DENIED)
    }

    private fun grant(permission: String) {
        Mockito.`when`(context.checkPermission(Mockito.eq(permission), Mockito.anyInt(), Mockito.anyInt()))
            .thenReturn(PackageManager.PERMISSION_GRANTED)
    }

    private fun isGranted(sdkInt: Int) = MediaReadPermissionCheckerImpl(context, sdkInt).isGranted()

    @Test
    fun isGrantedShouldBeTrueIfOnlySelectedItemsAreGrantedOnApi34() {
        grant(Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)

        assertTrue(isGranted(Build.VERSION_CODES.UPSIDE_DOWN_CAKE))
    }

    @Test
    fun isGrantedShouldBeTrueIfAnyMediaTypeIsGrantedOnApi33() {
        grant(Manifest.permission.READ_MEDIA_VIDEO)

        assertTrue(isGranted(Build.VERSION_CODES.TIRAMISU))
    }

    @Test
    fun isGrantedShouldBeFalseIfOnlySelectedItemsAreGrantedOnApi33() {
        grant(Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED)

        assertFalse(isGranted(Build.VERSION_CODES.TIRAMISU))
    }

    @Test
    fun isGrantedShouldBeTrueIfExternalStorageIsGrantedBelowApi33() {
        grant(Manifest.permission.READ_EXTERNAL_STORAGE)

        assertTrue(isGranted(Build.VERSION_CODES.S_V2))
    }

    @Test
    fun isGrantedShouldBeFalseIfNothingIsGranted() {
        assertFalse(isGranted(Build.VERSION_CODES.UPSIDE_DOWN_CAKE))
    }
}
