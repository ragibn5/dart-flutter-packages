package com.ragibn5.media.provider.media_provider_android.features.volume.models

import android.os.Environment
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class VolumeStateTest {
    @Test
    fun fromShouldReturnMatchingStateIfRawIsKnown() {
        assertEquals(VolumeState.MOUNTED_READ_ONLY, VolumeState.from(Environment.MEDIA_MOUNTED_READ_ONLY))
    }

    @Test
    fun fromShouldReturnUnknownIfRawIsNull() {
        assertEquals(VolumeState.UNKNOWN, VolumeState.from(null))
    }

    @Test
    fun fromShouldReturnUnknownIfRawIsNotKnown() {
        assertEquals(VolumeState.UNKNOWN, VolumeState.from("frozen"))
    }
}
