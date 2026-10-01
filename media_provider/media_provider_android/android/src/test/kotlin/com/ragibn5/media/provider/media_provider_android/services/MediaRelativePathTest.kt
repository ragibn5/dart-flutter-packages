package com.ragibn5.media.provider.media_provider_android.services

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * [MediaRelativePath] turns the absolute file path of `_data` into the
 * directory `RELATIVE_PATH` would have reported.
 *
 * The volume roots are passed in, so these tests cover only the stripping the
 * mapper does with whatever the device reported.
 */
internal class MediaRelativePathTest {
    private val emulated = "/storage/emulated/0"
    private val removable = "/storage/1A2B-3C4D"

    private fun fromData(data: String?, roots: List<String> = listOf(emulated)) =
        MediaRelativePath.fromData(data, roots)

    @Test
    fun `drops the volume root and the file name`() {
        assertEquals("DCIM/Camera/", fromData("$emulated/DCIM/Camera/cat.png"))
    }

    @Test
    fun `keeps every directory below the volume root`() {
        assertEquals("DCIM/DCIM/Camera/", fromData("$emulated/DCIM/DCIM/Camera/cat.png"))
        assertEquals("Movies/Trip/2026/", fromData("$emulated/Movies/Trip/2026/clip.mp4"))
    }

    @Test
    fun `reads a file in the volume root as the volume root itself`() {
        assertEquals("", fromData("$emulated/cat.png"))
    }

    @Test
    fun `reads the path on whichever volume it was given`() {
        val roots = listOf(emulated, removable)

        assertEquals("DCIM/Camera/", fromData("$removable/DCIM/Camera/cat.png", roots))
        assertEquals("DCIM/Camera/", fromData("$emulated/DCIM/Camera/cat.png", roots))
    }

    @Test
    fun `reads a volume rooted anywhere the device names`() {
        assertEquals("DCIM/", fromData("/mnt/sdcard/DCIM/cat.png", listOf("/mnt/sdcard")))
    }

    @Test
    fun `has no path for a missing or empty file path`() {
        assertNull(fromData(null))
        assertNull(fromData(""))
    }

    @Test
    fun `has no path for a file path outside every volume root`() {
        assertNull(fromData("cat.png"))
        assertNull(fromData("/cat.png"))
        assertNull(fromData("/data/media/0/DCIM/cat.png"))
        assertNull(fromData("/storage/emulated/0/DCIM/cat.png", emptyList()))
    }

    @Test
    fun `has no path for a sibling that only starts with a volume root name`() {
        assertNull(fromData("/storage/emulated/01/DCIM/cat.png"))
    }
}
