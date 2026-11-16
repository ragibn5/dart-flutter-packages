package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeSpec
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class QuerySpec(
    val types: Set<MediaType>,
    val volumes: Set<VolumeSpec>,
)