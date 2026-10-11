package com.ragibn5.media.provider.media_provider_android.models

import kotlinx.serialization.Serializable

/**
 * The type of a volume.
 * */
@Serializable
internal enum class VolumeType {
    /**
     * The primary shared external volume.
     * */
    PRIMARY,

    /**
     * A removable SD card, typically enclosed within device casing.
     * */
    SD_CARD,

    /**
     * A removable USB drive, connected via the USB interface.
     * */
    USB_DRIVE,

    /**
     * A removable drive, but could not decide whether it is an SD card or a USB drive.
     * */
    UNKNOWN_REMOVABLE,

    /**
     * Unknown volume type.
     * */
    UNKNOWN,
}
