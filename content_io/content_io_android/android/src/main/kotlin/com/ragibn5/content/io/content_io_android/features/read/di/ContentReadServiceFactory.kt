package com.ragibn5.content.io.content_io_android.features.read.di

import android.content.Context
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadServiceImpl
import com.ragibn5.content.io.content_io_android.features.read.services.ContentSourceOpener

internal object ContentReadServiceFactory {
    fun create(context: Context): ContentReadService {
        return ContentReadServiceImpl(
            contentSourceOpener = ContentSourceOpener(contentResolver = context.contentResolver),
        )
    }
}
