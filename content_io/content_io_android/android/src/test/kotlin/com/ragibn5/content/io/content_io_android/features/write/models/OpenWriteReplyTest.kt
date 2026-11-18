package com.ragibn5.content.io.content_io_android.features.write.models

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenWriteReplyTest {
    private fun kindOf(reply: OpenWriteReply): String =
        Json.parseToJsonElement(Json.encodeToString<OpenWriteReply>(reply))
            .jsonObject.getValue("kind").jsonPrimitive.content

    @Test
    fun encodeShouldUseDescriptorKindIfReplyIsDescriptor() {
        assertEquals("descriptor", kindOf(OpenWriteReply.Descriptor(fd = 42)))
    }

    @Test
    fun encodeShouldUseChannelKindIfReplyIsChannel() {
        assertEquals("channel", kindOf(OpenWriteReply.Channel(sessionId = "session-1")))
    }
}
