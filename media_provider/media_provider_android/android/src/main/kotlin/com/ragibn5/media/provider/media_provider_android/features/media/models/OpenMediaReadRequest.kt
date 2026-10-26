package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenMediaReadRequest(
    val contentUri: String,
)