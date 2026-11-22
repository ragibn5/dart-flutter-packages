package com.ragibn5.content.io.content_io_android.features.hash.handlers

import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHash
import com.ragibn5.content.io.content_io_android.features.hash.models.ContentHashAlgorithm
import com.ragibn5.content.io.content_io_android.features.hash.models.HashContentRequest
import com.ragibn5.content.io.content_io_android.features.read.constants.OpenReadExceptionCodes
import com.ragibn5.content.io.content_io_android.testing.assertContentIoError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class HashContentRequestHandlerTest {
    private val hash = ContentHash(ContentHashAlgorithm.SHA_256, "2cf24dba")
    private val hashedRequests = mutableListOf<HashContentRequest>()
    private val handler = HashContentRequestHandler({ request ->
        hashedRequests.add(request)
        hash
    })

    @Test
    fun methodShouldBeHashContent() {
        assertEquals("hashContent", handler.method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("hashContent", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertContentIoError(OpenReadExceptionCodes.INVALID_REQUEST) {
            handler.handle(MethodCall("hashContent", "{"))
        }
    }

    @Test
    fun handleShouldHashDecodedRequestAndReturnHashAsJson() = runTest {
        val encoded = handler.handle(
            MethodCall(
                "hashContent",
                """{"uri":"content://media/external/images/media/1","algorithm":"sha256"}""",
            ),
        )

        assertEquals(
            listOf(HashContentRequest("content://media/external/images/media/1", ContentHashAlgorithm.SHA_256)),
            hashedRequests,
        )
        assertEquals(hash, Json.decodeFromString<ContentHash>(encoded as String))
    }
}
