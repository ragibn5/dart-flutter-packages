package com.ragibn5.media.provider.media_provider_android.features.media.models

internal data class MediaColumn(
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