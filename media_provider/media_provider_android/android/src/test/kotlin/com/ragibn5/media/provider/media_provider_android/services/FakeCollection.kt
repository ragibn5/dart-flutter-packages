package com.ragibn5.media.provider.media_provider_android.services

import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollection
import com.ragibn5.media.provider.media_provider_android.models.MediaType

/**
 * A [com.ragibn5.media.provider.media_provider_android.models.MediaStoreCollection] the test chooses, so no test depends on what
 * `MediaStore.*.EXTERNAL_CONTENT_URI` holds on a real device.
 */
internal class FakeCollection(
    override val type: MediaType,
    override val uri: Uri = fakeUri("content://test/$type"),
) : MediaStoreCollection
