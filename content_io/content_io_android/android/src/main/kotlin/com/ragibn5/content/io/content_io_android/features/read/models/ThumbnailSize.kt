package com.ragibn5.content.io.content_io_android.features.read.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * The size a thumbnail is requested at, in pixels.
 *
 * Note: The provider returns the thumbnail closest to this size, which may
 * differ from it.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class ThumbnailSize(
    /** The width, in pixels; must be positive. */
    val width: Int,
    /** The height, in pixels; must be positive. */
    val height: Int,
)
