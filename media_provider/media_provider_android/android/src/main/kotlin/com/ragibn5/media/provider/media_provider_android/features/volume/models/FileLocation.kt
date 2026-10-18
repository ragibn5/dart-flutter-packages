package com.ragibn5.media.provider.media_provider_android.features.volume.models

internal data class FileLocation(
    /**
     * The identity of the volume that contains the file.
     * */
    val volumeIdentity: VolumeIdentity,

    /**
     * The path to the parent directory of the file.
     * */
    val relativeParentPath: String,

    /**
     * The name of the file, including the extension.
     * */
    val fileNameWithExtension: String,
)