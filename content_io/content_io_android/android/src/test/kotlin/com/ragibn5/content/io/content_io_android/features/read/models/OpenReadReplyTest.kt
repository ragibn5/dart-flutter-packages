package com.ragibn5.content.io.content_io_android.features.read.models

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenReadReplyTest {
    private fun kindOf(reply: OpenReadReply): String =
        Json.parseToJsonElement(Json.encodeToString<OpenReadReply>(reply))
            .jsonObject.getValue("kind").jsonPrimitive.content

    @Test
    fun encodeShouldUseDescriptorKindIfReplyIsDescriptor() {
        assertEquals(
            "descriptor",
            kindOf(OpenReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)),
        )
    }

    @Test
    fun encodeShouldUseChannelKindIfReplyIsChannel() {
        assertEquals(
            "channel",
            kindOf(OpenReadReply.Channel(sessionId = "session-1", sizeInBytes = null, isSeekable = false)),
        )
    }
}
