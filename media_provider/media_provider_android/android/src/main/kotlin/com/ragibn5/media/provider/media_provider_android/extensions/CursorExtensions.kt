package com.ragibn5.media.provider.media_provider_android.extensions

import android.database.Cursor

internal fun Cursor.getLongOrNull(index: Int): Long? =
    if (isNull(index)) null
    else getLong(index)

internal fun Cursor.getIntOrNull(index: Int): Int? =
    if (isNull(index)) null
    else getInt(index)

internal fun Cursor.getStringOrNull(index: Int): String? =
    if (isNull(index)) null
    else getString(index)

internal fun Cursor.getBooleanOrNull(index: Int): Boolean? =
    getIntOrNull(index)?.let { it != 0 }
