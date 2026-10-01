package com.ragibn5.media.provider.media_provider_android

import android.net.Uri
import com.ragibn5.media.provider.media_provider_android.services.MediaUriBuilder
import io.flutter.plugin.common.MethodChannel

/**
 * What a [MethodChannel.Result] was told, captured for assertions.
 *
 * `MethodChannel.Result` is an interface, so recording it needs no framework.
 */
internal sealed interface MethodChannelReply {
    data class Success(val value: Any?) : MethodChannelReply
    data class Error(
        val code: String,
        val message: String?,
        val details: Any?,
    ) : MethodChannelReply

    data object NotImplemented : MethodChannelReply
}

/**
 * A [MethodChannel.Result] that records the reply it was given.
 *
 * Flutter permits exactly one terminal call per invocation, so a second call
 * overwrites the first.
 */
internal class RecordingMethodChannelResult : MethodChannel.Result {
    var reply: MethodChannelReply? = null
        private set

    override fun success(result: Any?) {
        reply = MethodChannelReply.Success(result)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        reply = MethodChannelReply.Error(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {
        reply = MethodChannelReply.NotImplemented
    }
}

/**
 * A [MediaUriBuilder] that never touches `ContentUris`.
 *
 * Records every row it was asked to address, and gives each the URI
 * `<collection>/<id>`.
 */
internal class FakeUriBuilder : MediaUriBuilder {
    private val requested = mutableListOf<Pair<Uri, Long>>()

    /** The URIs it was asked to build, in order. */
    val requestedUris: List<String>
        get() = requested.map { (uri, id) -> "$uri/$id" }

    /** The rows it was asked to address, in order. */
    val requestedRows: List<Pair<Uri, Long>>
        get() = requested

    override fun build(collection: Uri, id: Long): String =
        "$collection/$id".also { requested += collection to id }
}

/**
 * A [MediaVolumeRoots] naming the volumes a fake row may live on, so no test
 * depends on where a device mounts its storage.
 */
internal fun fakeVolumeRoots(vararg paths: String): MediaVolumeRoots =
    MediaVolumeRoots { paths.toList() }
