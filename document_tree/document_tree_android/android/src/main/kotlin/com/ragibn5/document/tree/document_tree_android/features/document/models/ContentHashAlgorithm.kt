package com.ragibn5.document.tree.document_tree_android.features.document.models

import android.annotation.SuppressLint
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * An algorithm a copy's content can be hashed with.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal enum class ContentHashAlgorithm(
    /** The algorithm's name, as `java.security.MessageDigest` takes it. */
    val digestName: String,
) {
    /** SHA-256. */
    @SerialName("sha256")
    SHA_256("SHA-256"),
}
