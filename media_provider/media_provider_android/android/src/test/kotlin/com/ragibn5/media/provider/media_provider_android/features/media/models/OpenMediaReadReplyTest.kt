package com.ragibn5.media.provider.media_provider_android.features.media.models

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenMediaReadReplyTest {
    private fun kindOf(reply: OpenMediaReadReply): String =
        Json.parseToJsonElement(Json.encodeToString<OpenMediaReadReply>(reply))
            .jsonObject.getValue("kind").jsonPrimitive.content

    @Test
    fun encodeShouldUseDescriptorKindIfReplyIsDescriptor() {
        assertEquals(
            "descriptor",
            kindOf(OpenMediaReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 2048, isSeekable = true)),
        )
    }

    @Test
    fun encodeShouldUseChannelKindIfReplyIsChannel() {
        assertEquals(
            "channel",
            kindOf(OpenMediaReadReply.Channel(sessionId = "session-1", sizeInBytes = null, isSeekable = false)),
        )
    }
}
