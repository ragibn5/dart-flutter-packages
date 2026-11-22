package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.Serializable

/**
 * A file copied into a tree.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class CopiedDocument(
    /** The copy. */
    val document: DocumentInfo,
    /**
     * The hash of the bytes written into the copy, made with the request's
     * [CopyDocumentRequest.hashAlgorithm]; `null` when it asked for none.
     */
    val contentHash: ContentHash? = null,
)
