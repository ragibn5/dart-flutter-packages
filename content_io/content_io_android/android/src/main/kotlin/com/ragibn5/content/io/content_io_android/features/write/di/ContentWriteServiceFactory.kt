package com.ragibn5.content.io.content_io_android.features.write.di

import android.content.Context
import com.ragibn5.content.io.content_io_android.features.write.services.ContentSinkOpener
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteService
import com.ragibn5.content.io.content_io_android.features.write.services.ContentWriteServiceImpl

internal object ContentWriteServiceFactory {
    fun create(context: Context): ContentWriteService {
        return ContentWriteServiceImpl(
            contentSinkOpener = ContentSinkOpener(contentResolver = context.contentResolver),
        )
    }
}
