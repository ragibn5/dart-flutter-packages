package com.ragibn5.media.provider.media_provider_android

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.services.FileLocationResolver
import com.ragibn5.media.provider.media_provider_android.services.MediaItemUriBuilder
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
 * A [MediaItemUriBuilder] that never touches `ContentUris`.
 *
 * Records every row it was asked to address, and gives each the URI
 * `<collection>/<id>`.
 */
internal class FakeItemUriBuilder : MediaItemUriBuilder {
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
 * @param isPrimary whether the volume reports itself as the primary one.
 * @param uuid the volume UUID.
 */
internal fun fakeFileLocationResolver(
    volumePath: String? = "/storage/emulated/0",
    isPrimary: Boolean = true,
    uuid: String? = null,
): FileLocationResolver {
    val storageManager = fakeStorageManagerReportingVolume(volumePath, isPrimary, uuid)
    return FileLocationResolver(
        storageManager = storageManager,
        volumePathResolver = VolumePathResolver(
            appContext = Mockito.mock(Context::class.java),
            storageManager = storageManager,
            // The volume path always comes from `StorageManager`, so the context
            // goes unused; finding a path is VolumePathResolver's own business,
            // covered by VolumePathResolverTest.
            sdkInt = Build.VERSION_CODES.R,
        ),
    )
}

/**
 * A [StorageManager] reporting a single volume, whatever file is looked up.
 *
 * @param volumePath the volume root, or `null` for a volume that reports none.
 */
internal fun fakeStorageManagerReportingVolume(
    volumePath: String?,
    isPrimary: Boolean = true,
    uuid: String? = null,
): StorageManager = fakeStorageManager(
    volumes = listOf(
        fakeVolume(isPrimary = isPrimary, uuid = uuid, directory = volumePath),
    ),
    primaryPath = volumePath,
)

/**
 * A [StorageVolume] reporting the given properties, and never the name the
 * `MediaStore` columns carry, since nothing reads it any more.
 *
 * @param directory the volume root, or `null` for a volume that reports none.
 */
internal fun fakeVolume(
    isPrimary: Boolean = false,
    uuid: String? = null,
    directory: String? = null,
): StorageVolume = Mockito.mock(StorageVolume::class.java).apply {
    Mockito.`when`(this.isPrimary).thenReturn(isPrimary)
    Mockito.`when`(this.uuid).thenReturn(uuid)
    Mockito.`when`(this.directory).thenReturn(directory?.let(::File))
}

/**
 * A [StorageManager] reporting the given volumes as the device's storage.
 *
 * Each volume is mounted at the root matching its UUID, or at [primaryPath] when
 * it reports itself as the primary one.
 *
 * @param primaryPath where the primary volume is mounted, or `null` for a device
 *   with no primary volume at all.
 */
internal fun fakeStorageManager(
    volumes: List<StorageVolume>,
    primaryPath: String? = "/storage/emulated/0",
    volumeDirectories: Map<String?, String?> = emptyMap(),
): StorageManager {
    // Read off the volumes up front: Mockito treats a call on one mock made while
    // another's stubbing is open as a stubbing of its own.
    val roots: List<String?> = volumes.map { volume ->
        if (volume.isPrimary) primaryPath else volumeDirectories[volume.uuid]
    }
    val primary = volumes.indices.firstOrNull { volumes[it].isPrimary }?.let(volumes::get)

    return Mockito.mock(StorageManager::class.java).apply {
        Mockito.`when`(storageVolumes).thenReturn(volumes)
        Mockito.`when`(primaryStorageVolume).thenReturn(primary)
        volumes.forEachIndexed { index, volume ->
            Mockito.`when`(volume.directory).thenReturn(roots[index]?.let(::File))
        }
        // `getStorageVolume` is only ever asked where a file might sit, so a
        // volume answers for any path under its own root.
        Mockito.`when`(getStorageVolume(Mockito.any(File::class.java))).thenAnswer { answer ->
            val path = (answer.arguments.first() as File).absolutePath
            roots.indices.firstOrNull { index ->
                roots[index]?.let { root -> path == root || path.startsWith("$root/") } == true
            }?.let(volumes::get)
        }
    }
}