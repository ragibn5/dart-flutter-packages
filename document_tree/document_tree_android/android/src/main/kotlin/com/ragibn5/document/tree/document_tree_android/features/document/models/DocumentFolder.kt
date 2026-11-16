package com.ragibn5.document.tree.document_tree_android.features.document.models

/**
 * A folder in a tree.
 */
internal data class DocumentFolder(
    /**
     * Its document ID, within the tree's provider.
     */
    val documentId: String,
    /**
     * Where it is, relative to the tree's root; empty for the root.
     */
    val path: String,
)
