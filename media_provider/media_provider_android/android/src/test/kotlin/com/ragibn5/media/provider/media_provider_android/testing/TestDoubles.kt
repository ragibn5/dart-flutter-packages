package com.ragibn5.media.provider.media_provider_android.testing

import com.ragibn5.media.provider.media_provider_android.exceptions.MediaProviderException
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

/**
 * [Mockito.any] for a Kotlin non-null parameter.
 *
 * Mockito's own returns `null`, which Kotlin rejects before the stub sees it.
 */
internal fun <T> anyOf(type: Class<T>): T {
    Mockito.any(type)
    @Suppress("UNCHECKED_CAST")
    return null as T
}

/**
 * Asserts that [block] throws a [MediaProviderException] with [code].
 *
 * @return the exception, for further assertions.
 */
internal inline fun assertProviderError(code: String, block: () -> Unit): MediaProviderException {
    val exception = assertFailsWith<MediaProviderException> { block() }
    assertEquals(code, exception.code)
    return exception
}

/** What a [MethodChannel.Result] was told. */
internal sealed interface Reply {
    data class Success(val value: Any?) : Reply
    data class Error(val code: String, val message: String?, val details: Any?) : Reply
    data object NotImplemented : Reply
}

/** A [MethodChannel.Result] that records the reply it was given. */
internal class RecordingResult : MethodChannel.Result {
    var reply: Reply? = null
        private set

    override fun success(result: Any?) {
        reply = Reply.Success(result)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        reply = Reply.Error(errorCode, errorMessage, errorDetails)
    }

    override fun notImplemented() {
        reply = Reply.NotImplemented
    }
}

/**
 * The value a mock must answer with to make a `Result`-returning method return
 * [result].
 *
 * Such a method returns the result unboxed on the JVM, so a stub answering with
 * the `Result` itself would be read as a success holding it.
 */
internal fun <T> unboxed(result: Result<T>): Any? =
    Result::class.java.getDeclaredMethod("unbox-impl").invoke(result)
