package com.ragibn5.user.provider.user_provider_android.models

import kotlin.test.Test
import kotlin.test.assertEquals

internal class UserIdentityTest {
    @Test
    fun `splits a uid into the user id and the app id`() {
        val identity = UserIdentity.fromUid(1010123)

        assertEquals(1010123, identity.uid)
        assertEquals(10, identity.userId)
        assertEquals(10123, identity.appId)
    }

    @Test
    fun `reports user zero for a uid below the app id range`() {
        val identity = UserIdentity.fromUid(4321)

        assertEquals(0, identity.userId)
        assertEquals(4321, identity.appId)
    }

    @Test
    fun `keeps uid and app id consistent with each other`() {
        val identity = UserIdentity.fromUid(2_345_678)

        assertEquals(identity.uid, identity.userId * UserIdentity.APP_ID_PER_USER + identity.appId)
    }

    @Test
    fun `app id is always below the apps reserved per user`() {
        val appId = UserIdentity.fromUid(99_999_999).appId

        assertEquals(true, appId in 0 until UserIdentity.APP_ID_PER_USER)
    }
}