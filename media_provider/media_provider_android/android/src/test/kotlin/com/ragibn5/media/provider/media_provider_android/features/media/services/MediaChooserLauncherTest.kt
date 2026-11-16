package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.app.Activity
import android.content.Intent
import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.testing.anyOf
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito

internal class MediaChooserLauncherTest {
    private val activity = Mockito.mock(Activity::class.java)
    private val intent = Mockito.mock(Intent::class.java)
    private val chooser = Mockito.mock(Intent::class.java)
    private val intents = Mockito.mockStatic(Intent::class.java).also {
        it.`when`<Intent> { Intent.createChooser(intent, "Share") }.thenReturn(chooser)
    }

    @AfterEach
    fun tearDown() = intents.close()

    @Test
    fun launchShouldFailWithNoActivityIfNoActivityIsAttached() {
        assertProviderError(MediaActionExceptionCodes.NO_ACTIVITY) {
            MediaChooserLauncher { null }.launch(intent, "Share")
        }
    }

    @Test
    fun launchShouldStartChooserWithTitleFromActivity() {
        MediaChooserLauncher { activity }.launch(intent, "Share")

        Mockito.verify(activity).startActivity(chooser)
    }

    @Test
    fun launchShouldFailWithPermissionDeniedIfActivityMayNotGrantAccess() {
        Mockito.doThrow(SecurityException("Permission Denial")).`when`(activity).startActivity(anyOf(Intent::class.java))

        assertProviderError(MediaActionExceptionCodes.PERMISSION_DENIED) {
            MediaChooserLauncher { activity }.launch(intent, "Share")
        }
    }
}
