package com.ragibn5.media.provider.media_provider_android.features.volume.models

import android.annotation.SuppressLint
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import kotlinx.serialization.Serializable
import java.io.File

@SuppressLint("UnsafeOptInUsageError")
@Serializable
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
) {
    val absoluteFilePath: String
        get() = listOf(
            volumeIdentity.volumePath,
            relativeParentPath,
            fileNameWithExtension
        ).joinToString(File.separator) { it.ensureNoTrailingSlash() }
}