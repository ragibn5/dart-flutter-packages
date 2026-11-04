package com.ragibn5.media.provider.media_provider_android.features.volume.models

import com.ragibn5.media.provider.media_provider_android.testing.primaryVolumeIdentity
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

internal class FileLocationTest {
    @Test
    fun absoluteFilePathShouldJoinVolumeParentAndName() {
        val location = FileLocation(primaryVolumeIdentity, "DCIM/Camera/", "IMG_0001.jpg")

        assertEquals("/storage/emulated/0/DCIM/Camera/IMG_0001.jpg", location.absoluteFilePath)
    }

    @Test
    fun absoluteFilePathShouldSkipParentIfFileIsAtVolumeRoot() {
        val location = FileLocation(primaryVolumeIdentity, "", "IMG_0001.jpg")

        assertEquals("/storage/emulated/0/IMG_0001.jpg", location.absoluteFilePath)
    }

    @Test
    fun encodeShouldIncludeAbsoluteFilePath() {
        val location = FileLocation(primaryVolumeIdentity, "DCIM/Camera/", "IMG_0001.jpg")

        val encoded = Json.parseToJsonElement(Json.encodeToString(location)).jsonObject

        assertEquals(
            "/storage/emulated/0/DCIM/Camera/IMG_0001.jpg",
            encoded.getValue("absoluteFilePath").jsonPrimitive.content,
        )
    }
}
