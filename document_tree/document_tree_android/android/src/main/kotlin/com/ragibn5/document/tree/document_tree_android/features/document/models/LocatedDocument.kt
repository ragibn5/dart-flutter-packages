package com.ragibn5.document.tree.document_tree_android.features.document.models

/**
 * A document in a tree, with the folder holding it.
 */
internal data class LocatedDocument(
    val folder: DocumentFolder,
    val row: DocumentRow,
)
