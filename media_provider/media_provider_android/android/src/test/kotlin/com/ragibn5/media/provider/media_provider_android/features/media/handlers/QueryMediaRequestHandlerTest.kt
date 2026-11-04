package com.ragibn5.media.provider.media_provider_android.features.media.handlers

import com.ragibn5.media.provider.media_provider_android.features.media.constants.MediaQueryExceptionCodes
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaItem
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaType
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeSpec
import com.ragibn5.media.provider.media_provider_android.testing.assertProviderError
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.TestCoroutineScheduler
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class QueryMediaRequestHandlerTest {
    private val item = MediaItem(
        type = MediaType.PHOTO,
        uri = "content://media/external/images/media/1",
        fileLocation = null,
        id = "1",
        name = "IMG_0001.jpg",
        mimeType = "image/jpeg",
        sizeInBytes = 2048,
        dateAddedInMillis = null,
        dateModifiedInMillis = null,
        dateTakenInMillis = null,
        ownerPackageName = null,
        data = null,
        isPending = null,
        isTrashed = null,
        isFavorite = null,
        isDownloaded = null,
    )
    private val queriedSpecs = mutableListOf<QuerySpec>()

    private fun handler(scheduler: TestCoroutineScheduler) = QueryMediaRequestHandler(
        mediaQueryService = { spec -> queriedSpecs += spec; listOf(item) },
        dispatcher = UnconfinedTestDispatcher(scheduler),
    )

    @Test
    fun methodShouldBeQueryMedia() = runTest {
        assertEquals("queryMedia", handler(testScheduler).method)
    }

    @Test
    fun handleShouldFailWithInvalidRequestIfArgumentIsMissing() = runTest {
        assertProviderError(MediaQueryExceptionCodes.INVALID_REQUEST) {
            handler(testScheduler).handle(MethodCall("queryMedia", null))
        }
    }

    @Test
    fun handleShouldFailIfArgumentCanNotBeDecoded() = runTest {
        assertProviderError(MediaQueryExceptionCodes.INVALID_REQUEST) {
            handler(testScheduler).handle(MethodCall("queryMedia", "{"))
        }
    }

    @Test
    fun handleShouldQueryDecodedSpecAndReturnItemsAsJson() = runTest {
        val reply = handler(testScheduler).handle(
            MethodCall("queryMedia", """{"types":["PHOTO"],"volumes":[{"type":"primary"}]}"""),
        )

        assertEquals(listOf(QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.Primary()))), queriedSpecs)
        assertEquals(listOf(item), Json.decodeFromString<List<MediaItem>>(reply))
    }
}
