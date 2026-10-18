package com.ragibn5.media.provider.media_provider_android.extensions

import org.junit.jupiter.api.Test
import java.io.File
import kotlin.test.assertEquals

/**
 * The path helpers the resolvers are built from. The slash matters in both
 * directions: a prefix match needs one, and `substring` must not eat a character
 * of the relative path.
 */
internal class PathExtensionsTest {
    @Test
    fun `ensureTrailingSlash leaves an existing slash alone`() {
        assertEquals("/DCIM/", "/DCIM/".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash adds a missing slash`() {
        assertEquals("/DCIM/", "/DCIM".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash keeps the root slash`() {
        assertEquals("/", "/".ensureTrailingSlash())
    }

    @Test
    fun `ensureTrailingSlash turns an empty string into the root`() {
        // Nothing to anchor to, so the helper falls back to the root. Callers
        // never pass an empty path, so this only pins the current behaviour.
        assertEquals(File.separator, "".ensureTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash drops an existing slash`() {
        assertEquals("/DCIM", "/DCIM/".ensureNoTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash leaves a slashless string alone`() {
        assertEquals("/DCIM", "/DCIM".ensureNoTrailingSlash())
    }

    @Test
    fun `ensureNoTrailingSlash turns the root into an empty string`() {
        assertEquals("", "/".ensureNoTrailingSlash())
    }
}
