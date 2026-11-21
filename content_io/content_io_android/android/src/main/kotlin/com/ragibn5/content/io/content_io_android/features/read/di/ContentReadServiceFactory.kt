package com.ragibn5.content.io.content_io_android.features.read.di

import android.content.Context
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadOpener
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadService
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadServiceImpl
import com.ragibn5.content.io.content_io_android.features.read.services.ImageThumbnails
import com.ragibn5.content.io.content_io_android.features.read.services.VideoFrameThumbnails

internal object ContentReadServiceFactory {
    fun create(context: Context): ContentReadService {
        return ContentReadServiceImpl(
            contentReadOpener = ContentReadOpener(
                contentResolver = context.contentResolver,
                imageThumbnails = ImageThumbnails(context.contentResolver),
                videoFrameThumbnails = VideoFrameThumbnails(context),
            ),
        )
    }
}
