package com.ragibn5.media.provider.media_provider_android.features.media.services

import android.net.Uri
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaQuery
import com.ragibn5.media.provider.media_provider_android.features.media.models.MediaType
import com.ragibn5.media.provider.media_provider_android.features.media.models.QuerySpec
import com.ragibn5.media.provider.media_provider_android.features.volume.models.VolumeSpec
import com.ragibn5.media.provider.media_provider_android.features.volume.services.VolumePathResolver
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import kotlin.test.assertEquals

internal class MediaQueryBuilderTest {
    private val photos = Mockito.mock(Uri::class.java)
    private val videos = Mockito.mock(Uri::class.java)
    private val storageManager = Mockito.mock(StorageManager::class.java)
    private val volumePathResolver = Mockito.mock(VolumePathResolver::class.java)
    private val primary = Mockito.mock(StorageVolume::class.java)
    private val sdCard = Mockito.mock(StorageVolume::class.java).also {
        Mockito.`when`(it.uuid).thenReturn("1A2B-3C4D")
    }

    private val builder = MediaQueryBuilder(
        storageManager,
        volumePathResolver,
        MediaCollectionUriResolver(photoCollection = { photos }, videoCollection = { videos }),
    )

    init {
        Mockito.`when`(storageManager.primaryStorageVolume).thenReturn(primary)
        Mockito.`when`(storageManager.storageVolumes).thenReturn(listOf(primary, sdCard))
        Mockito.`when`(volumePathResolver.resolve(primary)).thenReturn("/storage/emulated/0")
        Mockito.`when`(volumePathResolver.resolve(sdCard)).thenReturn("/storage/1A2B-3C4D")
    }

    private fun photoQuery(prefix: String) = MediaQuery(
        type = MediaType.PHOTO,
        uri = photos,
        selection = "_data LIKE ?",
        selectionArgs = arrayOf("$prefix%"),
    )

    @Test
    fun buildShouldQueryPrimaryVolumeRootIfSpecIsPrimaryWithoutScope() {
        val queries = builder.build(QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.Primary())))

        assertEquals(listOf(photoQuery("/storage/emulated/0/")), queries)
    }

    @Test
    fun buildShouldQueryVolumeWithMatchingUuidIfSpecIsExternal() {
        val queries = builder.build(QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.External("1A2B-3C4D"))))

        assertEquals(listOf(photoQuery("/storage/1A2B-3C4D/")), queries)
    }

    @Test
    fun buildShouldQueryScopeFolderIfScopeIsGiven() {
        val queries = builder.build(
            QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.Primary(relativePathScope = "/DCIM/Camera/"))),
        )

        assertEquals(listOf(photoQuery("/storage/emulated/0/DCIM/Camera/")), queries)
    }

    @Test
    fun buildShouldBuildOneQueryPerTypeAndVolume() {
        val queries = builder.build(
            QuerySpec(
                setOf(MediaType.PHOTO, MediaType.VIDEO),
                setOf(VolumeSpec.Primary(), VolumeSpec.External("1A2B-3C4D")),
            ),
        )

        assertEquals(
            listOf(
                MediaType.PHOTO to photos,
                MediaType.PHOTO to photos,
                MediaType.VIDEO to videos,
                MediaType.VIDEO to videos,
            ),
            queries.map { it.type to it.uri },
        )
    }

    @Test
    fun buildShouldSkipVolumeIfNoVolumeHasUuid() {
        val queries = builder.build(QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.External("5E6F-7A8B"))))

        assertEquals(emptyList(), queries)
    }

    @Test
    fun buildShouldSkipVolumeIfPathCanNotBeResolved() {
        Mockito.`when`(volumePathResolver.resolve(sdCard)).thenReturn(null)

        val queries = builder.build(QuerySpec(setOf(MediaType.PHOTO), setOf(VolumeSpec.External("1A2B-3C4D"))))

        assertEquals(emptyList(), queries)
    }
}
