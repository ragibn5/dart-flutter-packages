package com.ragibn5.content.io.content_io_android.features.read.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class OpenReadRequest(
    val uri: String,
)