package com.ragibn5.media.provider.media_provider_android.models

import android.os.Environment
import com.ragibn5.media.provider.media_provider_android.models.VolumeState.Companion.from
import kotlinx.serialization.Serializable

/**
 * The state of a volume.
 *
 * Each constant stands for the matching `android.os.Environment.MEDIA_*` state a
 * volume reports; see [from] for how a raw state maps onto one.
 * */
@Serializable
internal enum class VolumeState(
    private val raw: String?,
) {
    /**
     * The volume is mounted, and can be read from and written to.
     * */
    MOUNTED(Environment.MEDIA_MOUNTED),

    /**
     * The volume is mounted, but only for reading.
     * */
    MOUNTED_READ_ONLY(Environment.MEDIA_MOUNTED_READ_ONLY),

    /**
     * The volume is not mounted.
     * */
    UNMOUNTED(Environment.MEDIA_UNMOUNTED),

    /**
     * The volume is being checked, which happens after it was mounted.
     * */
    CHECKING(Environment.MEDIA_CHECKING),

    /**
     * The volume is being ejected.
     * */
    EJECTING(Environment.MEDIA_EJECTING),

    /**
     * The volume has been removed, and is safe to unmount.
     * */
    REMOVED(Environment.MEDIA_REMOVED),

    /**
     * The volume was removed without being unmounted first.
     * */
    BAD_REMOVAL(Environment.MEDIA_BAD_REMOVAL),

    /**
     * The volume is unmounted, and cannot be mounted.
     * */
    UNMOUNTABLE(Environment.MEDIA_UNMOUNTABLE),

    /**
     * The volume is unmounted, and carries no filesystem to mount.
     * */
    NO_FILESYSTEM(Environment.MEDIA_NOFS),

    /**
     * The volume reports no state, or one this plugin does not know.
     * */
    UNKNOWN(null);

    companion object {
        /** The states a raw `Environment.MEDIA_*` value maps onto. */
        private val byRaw = entries.filter { it.raw != null }.associateBy { it.raw }

        /**
         * The state a volume reports as [raw].
         *
         * [UNKNOWN] when [raw] is `null`, or names a state added by a later Android release.
         */
        fun from(raw: String?): VolumeState = byRaw[raw] ?: UNKNOWN
    }
}