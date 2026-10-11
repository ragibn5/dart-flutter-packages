package com.ragibn5.media.provider.media_provider_android.models;

import android.os.Environment
import kotlinx.serialization.Serializable

@Serializable
internal enum class VolumeState(private val raw: String?) {
    MOUNTED(Environment.MEDIA_MOUNTED),
    MOUNTED_READ_ONLY(Environment.MEDIA_MOUNTED_READ_ONLY),
    UNMOUNTED(Environment.MEDIA_UNMOUNTED),
    CHECKING(Environment.MEDIA_CHECKING),
    EJECTING(Environment.MEDIA_EJECTING),
    REMOVED(Environment.MEDIA_REMOVED),
    BAD_REMOVAL(Environment.MEDIA_BAD_REMOVAL),
    UNMOUNTABLE(Environment.MEDIA_UNMOUNTABLE),
    NO_FILESYSTEM(Environment.MEDIA_NOFS),
    UNKNOWN(null);

    companion object {
        private val byRaw = entries.filter { it.raw != null }.associateBy { it.raw }
        fun from(raw: String?): VolumeState = byRaw[raw] ?: UNKNOWN
    }
}