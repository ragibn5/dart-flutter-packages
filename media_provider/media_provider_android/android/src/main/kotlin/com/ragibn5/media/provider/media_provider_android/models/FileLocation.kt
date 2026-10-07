package com.ragibn5.media.provider.media_provider_android.models

internal data class FileLocation(
    val volumeInfo: VolumeInfo,
    val relativeParentPath: String,
    val fileNameWithExtension: String,
)