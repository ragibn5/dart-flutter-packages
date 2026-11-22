package com.ragibn5.content.io.content_io_android.features.hash.di

import android.content.Context
import com.ragibn5.content.io.content_io_android.features.hash.services.ContentHashService
import com.ragibn5.content.io.content_io_android.features.hash.services.ContentHashServiceImpl
import com.ragibn5.content.io.content_io_android.features.read.services.ContentReadOpener
import com.ragibn5.content.io.content_io_android.features.read.services.ImageThumbnails
import com.ragibn5.content.io.content_io_android.features.read.services.VideoFrameThumbnails

internal object ContentHashServiceFactory {
    fun create(context: Context): ContentHashService {
        return ContentHashServiceImpl(
            contentReadOpener = ContentReadOpener(
                contentResolver = context.contentResolver,
                imageThumbnails = ImageThumbnails(context.contentResolver),
                videoFrameThumbnails = VideoFrameThumbnails(context),
            ),
        )
    }
}
