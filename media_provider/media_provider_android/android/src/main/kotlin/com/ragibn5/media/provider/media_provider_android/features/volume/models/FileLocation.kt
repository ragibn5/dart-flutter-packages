package com.ragibn5.media.provider.media_provider_android.features.volume.models

import android.annotation.SuppressLint
import com.ragibn5.media.provider.media_provider_android.extensions.ensureNoTrailingSlash
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.ExperimentalSerializationApi
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
    /**
     * The file's absolute path.
     *
     * This is a computed property, joining the volume's path, the parent path and the name.
     */
    @OptIn(ExperimentalSerializationApi::class)
    @EncodeDefault
    val absoluteFilePath: String = listOf(
        volumeIdentity.volumePath,
        relativeParentPath,
        fileNameWithExtension
    )
        .map { it.ensureNoTrailingSlash() }
        .filter { it.isNotEmpty() }
        .joinToString(File.separator)
}