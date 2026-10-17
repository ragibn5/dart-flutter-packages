package com.ragibn5.media.provider.media_provider_android.models

internal data class FileLocation(
    val volumeIdentity: VolumeIdentity,
    val relativeParentPath: String,
    val fileNameWithExtension: String,
)