package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.services.MediaUriBuilder
import com.ragibn5.media.provider.media_provider_android.services.VolumePathResolver
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import java.io.File

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
 * A real [FileLocationResolver] over mocked Android storage classes, so no test
 * depends on where a device mounts its storage.
 *
 * [StorageManager], [StorageVolume] and [Context] are all concrete classes or
 * interfaces, so Mockito substitutes them. The resolver's own path arithmetic is
 * exercised for real; only the platform lookups are faked.
 *
 * @param volumePath the volume root `DATA` rows are expected to sit under. A
 *   `null` volume reports no root at all, which is how "the file is on no known
 *   volume" is tested.
 * @param mediaStoreVolumeName what `StorageVolume` reports from API 30 on, the
 *   name callers actually use at that level.
 * @param isPrimary whether the volume is the primary one, which the pre-API 30
 *   fallback names.
 * @param uuid the volume UUID, lowercased by the pre-API 30 fallback.
 * @param sdkInt the SDK level to resolve at. Defaults to API 30 so the real code
 *   path runs; `Build.VERSION.SDK_INT` is 0 off-device and would silently take
 *   the fallback instead.
 */
internal fun fakeFileLocationResolver(
    volumePath: String? = "/storage/emulated/0",
    mediaStoreVolumeName: String? = MediaStore.VOLUME_EXTERNAL_PRIMARY,
    isPrimary: Boolean = true,
    uuid: String? = null,
    sdkInt: Int = Build.VERSION_CODES.R,
): FileLocationResolver {
    val storageManager = Mockito.mock(StorageManager::class.java)
    val volume = Mockito.mock(StorageVolume::class.java)

    Mockito.`when`(storageManager.getStorageVolume(Mockito.any(File::class.java)))
        .thenReturn(volume)
    Mockito.`when`(volume.directory).thenReturn(volumePath?.let(::File))
    Mockito.`when`(volume.isPrimary).thenReturn(isPrimary)
    Mockito.`when`(volume.uuid).thenReturn(uuid)
    // Only read at API 30 and above, so stubbing it unconditionally costs nothing.
    Mockito.`when`(volume.mediaStoreVolumeName).thenReturn(mediaStoreVolumeName)

    // The volume path always comes from `StorageManager`, so the context goes
    // unused however [sdkInt] is set; finding a path is VolumePathResolver's
    // own business, covered by VolumePathResolverTest.
    return FileLocationResolver(
        storageManager,
        VolumePathResolver(
            appContext = Mockito.mock(Context::class.java),
            storageManager = storageManager,
            sdkInt = Build.VERSION_CODES.R,
        ),
        sdkInt,
    )
}
