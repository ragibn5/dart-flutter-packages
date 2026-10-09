package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaQueryRequest(
    val types: Set<MediaType>,
    val volumes: Set<StorageVolumeSpec>,
)