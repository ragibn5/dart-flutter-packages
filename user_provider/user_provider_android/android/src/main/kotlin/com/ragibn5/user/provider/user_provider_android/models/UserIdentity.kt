package com.ragibn5.user.provider.user_provider_android.models

import kotlinx.serialization.Serializable

/**
 * Who the running process belongs to, as reported by `getIdentity`.
 *
 * Android packs both the id of the user the process runs under and the id of the
 * app within that user into a single uid, so the three values here are not
 * independent of each other.
 */
@Serializable
internal data class UserIdentity(
    /**
     * The uid of the running process, as reported by `Process.myUid()`, for example `1010123`.
     */
    val uid: Int,

    /**
     * The id of the user the process runs under, that is `uid / [APP_ID_PER_USER]`, for example `10`.
     */
    val userId: Int,

    /**
     * The id of the app within its user, that is `uid % [APP_ID_PER_USER]`, for example `10123`.
     */
    val appId: Int,
) {
    companion object {
        /**
         * How many app ids Android reserves per user, and therefore the base used to split a uid
         * into a user id and an app id.
         */
        const val APP_ID_PER_USER = 100000

        /**
         * Splits [uid] the way Android lays it out.
         */
        fun fromUid(uid: Int) = UserIdentity(
            uid = uid,
            userId = uid / APP_ID_PER_USER,
            appId = uid % APP_ID_PER_USER,
        )
    }
}