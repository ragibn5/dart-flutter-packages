package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.OpenMediaReadExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaReadReply
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenThumbnailReadRequest
import com.ragibn5.media.provider.media_provider_android.features.media.models.ThumbnailSize
import com.ragibn5.media.provider.media_provider_android.testing.FakeMediaReadService
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class OpenThumbnailReadRequestHandlerTest {
    private val reply = OpenMediaReadReply.Descriptor(fd = 42, offset = 0, sizeInBytes = 512, isSeekable = true)
    private val service = FakeMediaReadService(reply = reply)
    private val handler = OpenThumbnailReadRequestHandler(service)

    @Test
    fun methodShouldBeOpenThumbnailReadSession() {
        assertEquals("openThumbnailReadSession", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openThumbnailReadSession", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertProviderError(OpenMediaReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("openThumbnailReadSession", "{"))
        }
    }

    @Test
    fun handleShouldOpenDecodedRequestAndReturnReplyAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall(
                "openThumbnailReadSession",
                """{"contentUri":"content://media/external/images/media/1","size":{"width":256,"height":256}}""",
            ),
        )

        assertEquals(
            listOf<Any>(OpenThumbnailReadRequest("content://media/external/images/media/1", ThumbnailSize(256, 256))),
            service.openedRequests,
        )
        assertEquals(reply, Json.decodeFromString<OpenMediaReadReply>(encoded as String))
    }
}
