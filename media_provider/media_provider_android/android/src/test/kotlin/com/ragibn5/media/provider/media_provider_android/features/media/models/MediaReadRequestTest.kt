package com.ragibn5.media.provider.media_provider_android.features.media.models

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class MediaReadRequestTest {
    @Test
    fun startShouldBeZeroIfNotGiven() {
        assertEquals(0L, MediaReadRequest(sessionId = "session-1", length = 8).start)
    }

    @Test
    fun shouldThrowIllegalArgumentExceptionIfStartIsNegative() {
        assertFailsWith<IllegalArgumentException> {
            MediaReadRequest(sessionId = "session-1", start = -1, length = 8)
        }
    }

    @Test
    fun shouldThrowIllegalArgumentExceptionIfLengthIsNegative() {
        assertFailsWith<IllegalArgumentException> {
            MediaReadRequest(sessionId = "session-1", start = 0, length = -1)
        }
    }
}
