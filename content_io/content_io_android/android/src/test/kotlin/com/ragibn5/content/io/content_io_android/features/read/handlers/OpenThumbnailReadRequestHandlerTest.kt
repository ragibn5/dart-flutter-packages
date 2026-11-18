package com.ragibn5.content.io.content_io_android.features.read.handlers

import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.features.read.models.OpenReadReply
import com.ragibn5.content.io.content_io_android.features.read.models.OpenThumbnailReadRequest
import com.ragibn5.content.io.content_io_android.features.read.models.ThumbnailSize
import com.ragibn5.content.io.content_io_android.testing.FakeContentReadService
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenThumbnailReadRequestHandlerTest {
    private val reply = OpenReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 512, isSeekable = true)
    private val service = FakeContentReadService(reply = reply)
    private val handler = OpenThumbnailReadRequestHandler(service)

    @Test
    fun methodShouldBeOpenThumbnailReadSession() {
        assertEquals("openThumbnailReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openThumbnailReadSession", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openThumbnailReadSession", "{"))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnReplyAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall(
                "openThumbnailReadSession",
                """{"uri":"content://media/external/images/media/1","size":{"width":256,"height":256}}""",
            ),
        )

        assertEquals(
            listOf<Any>(OpenThumbnailReadRequest("content://media/external/images/media/1", ThumbnailSize(256, 256))),
            service.openedRequests,
        )
        assertEquals(reply, Json.decodeFromString<OpenReadReply>(encoded as String))
    }
}
