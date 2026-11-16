package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.content.Intent
import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.features.media.models.OpenMediaWithRequest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.mockito.Answers
import org.mockito.Mockito
import kotlin.test.assertEquals

internal class OpenMediaWithServiceTest {
    private val launcher = Mockito.mock(MediaChooserLauncher::class.java)
    private val mimeTypeResolver = Mockito.mock(MediaMimeTypeResolver::class.java)
    private val service = OpenMediaWithServiceImpl(launcher, mimeTypeResolver)

    private val uri = Mockito.mock(Uri::class.java)
    private val uris = Mockito.mockStatic(Uri::class.java).also {
        it.`when`<Uri> { Uri.parse(CONTENT_URI) }.thenReturn(uri)
    }

    /** The action each intent was created with, in order. */
    private val actions = mutableListOf<String?>()
    private val intents = Mockito.mockConstruction(
        Intent::class.java,
        Mockito.withSettings().defaultAnswer(Answers.RETURNS_SELF),
    ) { _, context -> actions += context.arguments().firstOrNull() as String? }

    @AfterEach
    fun tearDown() {
        uris.close()
        intents.close()
    }

    private fun openWith(title: String? = null): Intent {
        service.openWith(OpenMediaWithRequest(CONTENT_URI, title))
        return intents.constructed().single()
    }

    @Test
    fun openWithShouldViewItemAsItsType() {
        Mockito.`when`(mimeTypeResolver.resolve(uri)).thenReturn("image/jpeg")

        val intent = openWith()

        assertEquals(listOf<String?>(Intent.ACTION_VIEW), actions)
        Mockito.verify(intent).setDataAndType(uri, "image/jpeg")
    }

    @Test
    fun openWithShouldViewItemAsAnyTypeIfTypeIsNotKnown() {
        Mockito.verify(openWith()).setDataAndType(uri, "*/*")
    }

    @Test
    fun openWithShouldGrantReadAccessToItem() {
        Mockito.verify(openWith()).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }

    @Test
    fun openWithShouldLaunchChooserWithTitle() {
        val intent = openWith(title = "Open with")

        Mockito.verify(launcher).launch(intent, "Open with")
    }

    private companion object {
        const val CONTENT_URI = "content://media/external/images/media/1"
    }
}
