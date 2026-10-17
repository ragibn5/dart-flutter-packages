package com.ragibn5.user.provider.user_provider_android.handlers

import android.os.Process
import com.ragibn5.user.provider.user_provider_android.MethodCallRequestHandler
import com.ragibn5.user.provider.user_provider_android.models.UserIdentity
import io.flutter.plugin.common.MethodCall
import kotlinx.serialization.json.Json

/**
 * Serves `getIdentity`: the uid of the running process, split into the user id
 * and the app id it encodes.
 */
internal class GetIdentityHandler(
    private val uidProvider: () -> Int = { Process.myUid() },
    private val json: Json = Json { ignoreUnknownKeys = true },
) : MethodCallRequestHandler {
    override val method = "getIdentity"

    override suspend fun handle(call: MethodCall): String =
        json.encodeToString(UserIdentity.fromUid(uidProvider()))
}