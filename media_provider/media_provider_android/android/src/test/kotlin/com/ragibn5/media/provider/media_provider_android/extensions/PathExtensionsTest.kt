package com.ragibn5.media.provider.media_provider_android.extensions

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class PathExtensionsTest {
    @Test
    fun ensureTrailingSlashShouldAddSlashIfMissing() {
        assertEquals("DCIM/Camera/", "DCIM/Camera".ensureTrailingSlash())
    }

    @Test
    fun ensureTrailingSlashShouldKeepPathIfSlashIsPresent() {
        assertEquals("DCIM/Camera/", "DCIM/Camera/".ensureTrailingSlash())
    }

    @Test
    fun ensureNoTrailingSlashShouldRemoveSlashIfPresent() {
        assertEquals("DCIM/Camera", "DCIM/Camera/".ensureNoTrailingSlash())
    }

    @Test
    fun ensureNoTrailingSlashShouldKeepPathIfSlashIsMissing() {
        assertEquals("DCIM/Camera", "DCIM/Camera".ensureNoTrailingSlash())
    }
}
