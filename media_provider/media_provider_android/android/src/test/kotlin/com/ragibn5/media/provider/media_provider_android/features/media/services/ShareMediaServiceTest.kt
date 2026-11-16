package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.features.media.models.ShareMediaRequest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Answers
import org.mockito.MockedConstruction
import org.mockito.Mockito
import kotlin.test.assertEquals

internal class ShareMediaServiceTest {
    private val launcher = Mockito.mock(MediaChooserLauncher::class.java)
    private val mimeTypeResolver = Mockito.mock(MediaMimeTypeResolver::class.java)
    private val service = ShareMediaServiceImpl(launcher, mimeTypeResolver)
    private val uris = Mockito.mockStatic(Uri::class.java)

    private val photo = givenItem("content://media/external/images/media/1", "image/jpeg")
    private val otherPhoto = givenItem("content://media/external/images/media/2", "image/png")
    private val video = givenItem("content://media/external/video/media/3", "video/mp4")

    /** The action each intent was created with, in order. */
    private val actions = mutableListOf<String?>()
    private val intents: MockedConstruction<Intent> = Mockito.mockConstruction(
        Intent::class.java,
        Mockito.withSettings().defaultAnswer(Answers.RETURNS_SELF),
    ) { _, context -> actions += context.arguments().firstOrNull() as String? }
    private val clip = Mockito.mock(ClipData::class.java)
    private val clips = Mockito.mockStatic(ClipData::class.java).also {
        it.`when`<ClipData> { ClipData.newRawUri(Mockito.isNull(), Mockito.any(Uri::class.java)) }.thenReturn(clip)
    }

    @AfterEach
    fun tearDown() {
        intents.close()
        clips.close()
        uris.close()
    }

    private class Item(val contentUri: String, val uri: Uri)

    /** An item at [contentUri] of [mimeType], or of no known type when `null`. */
    private fun givenItem(contentUri: String, mimeType: String?): Item {
        val uri = Mockito.mock(Uri::class.java)
        Mockito.`when`(mimeTypeResolver.resolve(uri)).thenReturn(mimeType)
        uris.`when`<Uri> { Uri.parse(contentUri) }.thenReturn(uri)
        return Item(contentUri, uri)
    }

    private fun share(vararg items: Item, title: String? = null): Intent {
        service.share(ShareMediaRequest(items.map { it.contentUri }, title))
        return intents.constructed().single()
    }

    @Test
    fun shareShouldSendItemIfOneIsShared() {
        val intent = share(photo)

        assertEquals(listOf<String?>(Intent.ACTION_SEND), actions)
        Mockito.verify(intent).putExtra(Intent.EXTRA_STREAM, photo.uri)
    }

    @Test
    fun shareShouldSendItemsAsListIfSeveralAreShared() {
        val intent = share(photo, video)

        assertEquals(listOf<String?>(Intent.ACTION_SEND_MULTIPLE), actions)
        Mockito.verify(intent).putParcelableArrayListExtra(Intent.EXTRA_STREAM, arrayListOf(photo.uri, video.uri))
    }

    @Test
    fun shareShouldUseExactTypeIfItemsHaveSameType() {
        Mockito.verify(share(photo)).type = "image/jpeg"
    }

    @Test
    fun shareShouldUseWildcardSubtypeIfItemsShareOnlyTopLevelType() {
        Mockito.verify(share(photo, otherPhoto)).type = "image/*"
    }

    @Test
    fun shareShouldUseAnyTypeIfTopLevelTypesDiffer() {
        Mockito.verify(share(photo, video)).type = "*/*"
    }

    @Test
    fun shareShouldUseAnyTypeIfTypeIsNotKnown() {
        val unknown = givenItem("content://media/external/file/4", null)

        Mockito.verify(share(unknown)).type = "*/*"
    }

    @Test
    fun shareShouldGrantReadAccessToEveryItem() {
        val intent = share(photo, video)

        Mockito.verify(clip).addItem(Mockito.any(ClipData.Item::class.java))
        Mockito.verify(intent).clipData = clip
        Mockito.verify(intent).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }

    @Test
    fun shareShouldLaunchChooserWithTitle() {
        val intent = share(photo, title = "Share")

        Mockito.verify(launcher).launch(intent, "Share")
    }
}
