package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaActionExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

internal class ShareMediaRequestHandlerTest {
    private val shared = mutableListOf<ShareMediaRequest>()
    private val handler = ShareMediaRequestHandler({ shared += it })

    @Test
    fun methodShouldBeShareMedia() {
        assertEquals("shareMedia", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("shareMedia", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertProviderError(MediaActionExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("shareMedia", "{"))
        }
    }

    @Test
    fun handleShouldShareDecodedRequestAndReturnNull() = runTest {
        val reply = handler.handle(
            MethodCall("shareMedia", """{"contentUris":["content://media/external/images/media/1"]}"""),
        )

        assertEquals(listOf(ShareMediaRequest(listOf("content://media/external/images/media/1"))), shared)
        assertNull(reply)
    }
}
