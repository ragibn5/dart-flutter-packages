package com.ragibn5.user.provider.user_provider_android

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMethodCodec
import java.nio.ByteBuffer

/**
 * A [BinaryMessenger] that records the handlers a plugin registers, so a
 * channel can be driven with the same bytes Flutter would use.
 */
internal class FakeBinaryMessenger : BinaryMessenger {
    /** Channel name to the handler registered on it. */
    val handlers = mutableMapOf<String, BinaryMessenger.BinaryMessageHandler?>()

    override fun send(channel: String, message: ByteBuffer?) = Unit

    override fun send(
        channel: String,
        message: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) =
        send(channel, message)

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?,
    ) {
        handlers[channel] = handler
    }

    /**
     * Delivers [call] to the handler on [channel] and returns the raw reply.
     *
     * A null buffer is Flutter's "not implemented" reply, so it is passed
     * through rather than treated as a missing reply.
     */
    fun dispatch(channel: String, call: MethodCall): ByteBuffer? {
        val handler = requireNotNull(handlers[channel]) { "No handler on '$channel'" }
        val reply = CapturingReply()
        // `encodeMethodCall` leaves the position at the end; the channel reads
        // from the start, so rewind before handing it over.
        val encoded = StandardMethodCodec.INSTANCE.encodeMethodCall(call).apply { flip() }
        handler.onMessage(encoded, reply)
        return reply.encoded
    }

    private class CapturingReply : BinaryMessenger.BinaryReply {
        var encoded: ByteBuffer? = null

        override fun reply(reply: ByteBuffer?) {
            encoded = reply
        }
    }
}

/** The `getIdentity` call the plugin serves. It takes no arguments. */
internal fun getIdentityCall(): MethodCall = MethodCall("getIdentity", null)
