package com.ragibn5.media.provider.media_provider_android.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class VolumeInfo(
    val identity: VolumeIdentity,
    val state: VolumeState,
)