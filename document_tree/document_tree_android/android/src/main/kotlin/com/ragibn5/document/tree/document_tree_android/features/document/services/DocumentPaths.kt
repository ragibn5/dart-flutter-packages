package com.ragibn5.document.tree.document_tree_android.features.document.services

/**
 * Paths within a tree, relative to its root, such as `DCIM/Camera/IMG_1.jpg`.
 */
internal object DocumentPaths {
    /**
     * [path] without leading or trailing slashes, or `null` if any of its
     * segments is empty, `.` or `..`.
     *
     * `/DCIM/Camera/` and `DCIM/Camera` are the same folder; an empty path is
     * the tree's root.
     */
    fun normalize(path: String): String? {
        val trimmed = path.trim('/')
        if (trimmed.isEmpty()) {
            return trimmed
        }

        val isValid = trimmed.split('/').none { it.isEmpty() || it == "." || it == ".." }
        return if (isValid) trimmed else null
    }

    /**
     * The segments of the normalized [path]; none for the root.
     */
    fun segments(path: String): List<String> = if (path.isEmpty()) emptyList() else path.split('/')

    /**
     * The path of [name] in the folder at [parentPath].
     */
    fun child(parentPath: String, name: String): String =
        if (parentPath.isEmpty()) name else "$parentPath/$name"

    /**
     * The path of the folder holding the normalized [path]; empty if it's in the root.
     */
    fun parent(path: String): String = path.substringBeforeLast('/', missingDelimiterValue = "")

    /**
     * The last segment of the normalized [path].
     */
    fun name(path: String): String = path.substringAfterLast('/')
}
