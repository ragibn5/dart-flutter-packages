package com.ragibn5.content.io.content_io_android.features.read.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A request to read the thumbnail of the content behind a URI.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenThumbnailReadRequest(
    /** The `content://` URI of the content whose thumbnail to read. */
    val uri: String,
    /** The size to request the thumbnail at. */
    val size: ThumbnailSize,
    /**
     * Whether a thumbnail much larger than [size] is scaled down to close to it,
     * as [android.content.ContentResolver.loadThumbnail] does.
     */
    val scaleDownToSize: Boolean = true,
    /** Whether a thumbnail meant to be shown rotated is rotated upright. */
    val rotateUpright: Boolean = true,
)
