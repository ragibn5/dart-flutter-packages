package com.ragibn5.media.provider.media_provider_android.models;

import kotlinx.serialization.Serializable

@Serializable
internal enum class VolumeType {
    PRIMARY,
    SD_CARD,
    USB_DRIVE,
    UNKNOWN_REMOVABLE, // removable, but SD vs. USB couldn't be determined
    UNKNOWN,           // not primary and not removable (e.g. adopted storage)
}