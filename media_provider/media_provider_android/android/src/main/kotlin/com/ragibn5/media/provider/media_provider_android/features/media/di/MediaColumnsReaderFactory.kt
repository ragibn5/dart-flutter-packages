package com.ragibn5.media.provider.media_provider_android.features.media.di

import android.database.Cursor
import android.os.Build
import com.ragibn5.media.provider.media_provider_android.features.media.services.MediaColumnsReader

internal class MediaColumnsReaderFactory(
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    val projection: List<String> = MediaColumnsReader.projectionFor(sdkInt)

    fun create(cursor: Cursor): MediaColumnsReader =
        MediaColumnsReader(cursor = cursor, sdkInt = sdkInt)
}