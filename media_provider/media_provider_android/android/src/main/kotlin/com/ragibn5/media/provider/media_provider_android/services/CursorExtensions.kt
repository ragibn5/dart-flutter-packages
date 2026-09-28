package com.ragibn5.media.provider.media_provider_android.services

import android.database.Cursor
import androidx.core.database.getIntOrNull

/**
 * Reads the column at [index] as a [Long], or `null` if the value is NULL.
 *
 * [Cursor.getLong] returns `0` for NULL, which would hide "unknown".
 */
internal fun Cursor.getLongOrNull(index: Int): Long? =
    if (isNull(index)) null
    else getLong(index)

/**
 * Reads the column at [index] as an [Int], or `null` if the value is NULL.
 *
 * [Cursor.getInt] returns `0` for NULL, which would hide "unknown".
 */
internal fun Cursor.getIntOrNull(index: Int): Int? =
    if (isNull(index)) null
    else getInt(index)

/**
 * Reads the column at [index] as a [String], or `null` if the value is NULL.
 *
 * [Cursor.getString]'s behavior for NULL is implementation-defined.
 */
internal fun Cursor.getStringOrNull(index: Int): String? =
    if (isNull(index)) null
    else getString(index)

/**
 * Reads the integer column at [index] as a [Boolean], or `null` if the value
 * is NULL.
 */
internal fun Cursor.getBooleanOrNull(index: Int): Boolean? =
    getIntOrNull(index)?.let { it != 0 }
