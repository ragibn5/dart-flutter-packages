package com.ragibn5.user.provider.user_provider_android.handlers

import com.ragibn5.user.provider.user_provider_android.models.UserIdentity
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.test.runTest
import kotlinx.serialization.json.Json
import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * `Process.myUid()` only exists on Android, so the handler reads the uid
 * through a provider the tests replace. Everything else is the real thing.
 */
internal class GetIdentityHandlerTest {
    private fun handlerFor(uid: Int) = GetIdentityHandler(uidProvider = { uid })

    @Test
    fun `serves the method the Dart side invokes`() {
        assertEquals("getIdentity", GetIdentityHandler().method)
    }

    @Test
    fun `replies with the uid it was given, split into a user id and an app id`() = runTest {
        val handler = handlerFor(1010123)

        val reply = handler.handle(MethodCall("getIdentity", null))

        assertEquals(
            UserIdentity(uid = 1010123, userId = 10, appId = 10123),
            Json.decodeFromString<UserIdentity>(reply),
        )
    }

    @Test
    fun `replies with the same identity for repeated calls`() = runTest {
        val handler = handlerFor(1010123)

        val first = handler.handle(MethodCall("getIdentity", null))

        assertEquals(first, handler.handle(MethodCall("getIdentity", null)))
    }

    @Test
    fun `ignores the arguments of the call`() = runTest {
        val handler = handlerFor(1010123)

        val reply = handler.handle(MethodCall("getIdentity", mapOf("uid" to 1)))

        assertEquals(
            UserIdentity(uid = 1010123, userId = 10, appId = 10123),
            Json.decodeFromString<UserIdentity>(reply),
        )
    }
}