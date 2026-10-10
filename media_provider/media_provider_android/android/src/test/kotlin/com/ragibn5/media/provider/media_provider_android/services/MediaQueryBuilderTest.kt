package com.ragibn5.media.provider.media_provider_android.services

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.provider.MediaStore
import com.ragibn5.media.provider.media_provider_android.fakeStorageManager
import com.ragibn5.media.provider.media_provider_android.fakeVolume
import com.ragibn5.media.provider.media_provider_android.models.MediaType
import com.ragibn5.media.provider.media_provider_android.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.models.VolumeSpec
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * [MediaQueryBuilder] expands a [QuerySpec] into one query per type and volume,
 * skipping volumes the device does not have.
 *
 * The `StorageManager` and the volume paths are faked, the collection URIs come
 * from an injected resolver, and the paths are absolute so a result never depends
 * on the machine running the tests.
 */
internal class MediaQueryBuilderTest {
    private val primaryPath = "/storage/emulated/0"
    private val externalPath = "/storage/1234-5678"

    private val photoUri: Uri = fakeUri("content://test/photo")
    private val videoUri: Uri = fakeUri("content://test/video")

    /**
     * A real resolver over fake URIs: `MediaStore`'s own collections are `null`
     * off-device, so the collections are supplied here instead.
     */
    private val collectionUriResolver = MediaCollectionUriResolver(
        photoCollection = { photoUri },
        videoCollection = { videoUri },
    )

    /** A device with the primary volume and one secondary volume mounted. */
    private val storageManager: StorageManager = fakeStorageManager(
        volumes = listOf(
            fakeVolume(isPrimary = true, uuid = "1111-1111"),
            fakeVolume(isPrimary = false, uuid = "1234-5678"),
        ),
        primaryPath = primaryPath,
        volumeDirectories = mapOf("1234-5678" to externalPath),
    )

    private fun builder(
        storageManager: StorageManager = this.storageManager,
        sdkInt: Int = Build.VERSION_CODES.R,
    ) = MediaQueryBuilder(
        storageManager = storageManager,
        volumePathResolver = VolumePathResolver(
            appContext = Mockito.mock(Context::class.java),
            storageManager = storageManager,
            sdkInt = sdkInt,
        ),
        collectionUriResolver = collectionUriResolver,
    )

    private fun spec(
        types: Set<MediaType> = setOf(MediaType.PHOTO),
        volumes: Set<VolumeSpec> = setOf(VolumeSpec.Primary),
    ) = QuerySpec(types = types, volumes = volumes)

    @Test
    fun `builds one query per requested type`() {
        val queries = builder().build(spec(types = setOf(MediaType.PHOTO, MediaType.VIDEO)))

        assertEquals(listOf(MediaType.PHOTO, MediaType.VIDEO), queries.map { it.type })
    }

    @Test
    fun `builds one query per requested volume`() {
        val queries = builder().build(
            spec(volumes = setOf(VolumeSpec.Primary, VolumeSpec.External("1234-5678"))),
        )

        assertEquals(
            listOf("$primaryPath/%", "$externalPath/%"),
            queries.map { it.selectionArgs?.single() },
        )
    }

    @Test
    fun `builds a query for every type and volume combination`() {
        val queries = builder().build(
            spec(
                types = setOf(MediaType.PHOTO, MediaType.VIDEO),
                volumes = setOf(VolumeSpec.Primary, VolumeSpec.External("1234-5678")),
            ),
        )

        assertEquals(4, queries.size)
    }

    @Test
    fun `queries the collection of its type`() {
        val queries = builder().build(spec(types = setOf(MediaType.PHOTO, MediaType.VIDEO)))

        assertEquals(listOf(photoUri, videoUri), queries.map { it.uri })
    }

    /**
     * The prefix the `LIKE` matches on. A missing slash would make it
     * `/storage/emulated/0%`, which also matches a sibling volume whose root
     * merely starts with the same characters.
     */
    @Test
    fun `pins each query to its volume root with a slash before the wildcard`() {
        val query = builder().build(spec()).single()

        assertEquals("${MediaStore.MediaColumns.DATA} LIKE ?", query.selection)
        assertEquals("$primaryPath/%", query.selectionArgs?.single())
    }

    @Test
    fun `does not let one volume's prefix match a sibling`() {
        val queries = builder().build(spec(volumes = setOf(VolumeSpec.External("1234-5678"))))

        val pattern = queries.single().selectionArgs!!.single()
        // `/storage/1234-5678%` would also match `/storage/1234-56789/...`.
        assertTrue(
            pattern.startsWith("/storage/1234-5678/"),
            "the root must be slash-terminated before the wildcard, was '$pattern'",
        )
    }

    @Test
    fun `matches an external volume by its UUID`() {
        val queries = builder()
            .build(spec(volumes = setOf(VolumeSpec.External("1234-5678"))))

        assertEquals("$externalPath/%", queries.single().selectionArgs?.single())
    }

    @Test
    fun `skips a volume the device does not have`() {
        val queries = builder().build(spec(volumes = setOf(VolumeSpec.External("9999-9999"))))

        assertEquals(emptyList(), queries)
    }

    @Test
    fun `still builds the other volumes when one is missing`() {
        val queries = builder().build(
            spec(volumes = setOf(VolumeSpec.Primary, VolumeSpec.External("9999-9999"))),
        )

        assertEquals(listOf("$primaryPath/%"), queries.map { it.selectionArgs?.single() })
    }

    @Test
    fun `skips the primary volume on a device that has none`() {
        val storageManager = fakeStorageManager(
            volumes = listOf(fakeVolume(isPrimary = false, uuid = "1234-5678")),
            primaryPath = null,
            volumeDirectories = mapOf("1234-5678" to externalPath),
        )

        assertEquals(emptyList(), builder(storageManager).build(spec()))
    }

    @Test
    fun `skips a volume whose path cannot be resolved`() {
        // Mounted, but nothing reports where — `VolumePathResolver` returns null,
        // and a `LIKE` on the literal string "null" would match nothing anyway.
        val storageManager = fakeStorageManager(
            volumes = listOf(fakeVolume(isPrimary = true, uuid = "1111-1111")),
            primaryPath = null,
        )

        assertEquals(emptyList(), builder(storageManager).build(spec()))
    }

    @Test
    fun `builds nothing for a spec that requests nothing`() {
        assertEquals(emptyList(), builder().build(spec(types = emptySet(), volumes = emptySet())))
    }

    @Test
    fun `builds a query per distinct type, not per repeated entry`() {
        val queries = builder().build(
            QuerySpec(
                types = setOf(MediaType.PHOTO, MediaType.PHOTO, MediaType.VIDEO),
                volumes = setOf(VolumeSpec.Primary),
            ),
        )

        assertEquals(listOf(MediaType.PHOTO, MediaType.VIDEO), queries.map { it.type })
    }
}