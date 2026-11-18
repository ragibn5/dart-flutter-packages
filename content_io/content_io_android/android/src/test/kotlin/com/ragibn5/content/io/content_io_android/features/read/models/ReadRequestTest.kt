package com.ragibn5.content.io.content_io_android.features.read.models

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class ReadRequestTest {
    @Test
    fun startShouldBeZeroIfNotGiven() {
        assertEquals(0L, ReadRequest(sessionId = "session-1", length = 8).start)
    }

    @Test
    fun shouldThrowIllegalArgumentExceptionIfStartIsNegative() {
        assertFailsWith<IllegalArgumentException> {
            ReadRequest(sessionId = "session-1", start = -1, length = 8)
        }
    }

    @Test
    fun shouldThrowIllegalArgumentExceptionIfLengthIsNegative() {
        assertFailsWith<IllegalArgumentException> {
            ReadRequest(sessionId = "session-1", start = 0, length = -1)
        }
    }
}
