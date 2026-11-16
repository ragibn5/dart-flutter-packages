package com.ragibn5.media.provider.media_provider_android.features.media.models

import android.annotation.SuppressLint
import com.ragibn5.media.provider.media_provider_android.features.volume.models.FileLocation
import kotlinx.serialization.Serializable

/**
 * A single media file tracked by the Android `MediaStore`.
 *
 * Fields here (most of them, unless noted) corresponds to a column defined in
 * [android.provider.MediaStore.MediaColumns]. See the documentation of that class
 * for more information about each field's possible values. If any field's behavior
 * deviates from the corresponding column documentation, it is explicitly documented
 * here, in the field's documentation.
 */
@SuppressLint("UnsafeOptInUsageError")
@Serializable
internal data class MediaItem(
    /**
     * The `MediaStore` collection this item belongs to.
     */
    val type: MediaType,

    /**
     * The `content://` URI used to open the item through `ContentResolver`.
     */
    val uri: String,

    /**
     * The location of the data file or null if not applicable.
     *
     * > Note: May be null if the media item is not backed by a physical file.
     * */
    val fileLocation: FileLocation?,

    override val id: String,
    override val name: String?,
    override val mimeType: String?,
    override val sizeInBytes: Long?,
    override val dateAddedInMillis: Long?,
    override val dateModifiedInMillis: Long?,
    override val dateTakenInMillis: Long?,
    override val ownerPackageName: String?,
    override val data: String?,
    override val isPending: Boolean?,
    override val isTrashed: Boolean?,
    override val isFavorite: Boolean?,
    override val isDownloaded: Boolean?,
) : MediaColumnProperties