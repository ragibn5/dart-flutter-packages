package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.provider.MediaStore
import android.util.Log
import com.ragibn5.document.tree.document_tree_android.features.tree.models.TreeLocation
import java.io.File

/**
 * Resolves where a tree is on the device's storage, confirmed, never guessed.
 *
 * Note:
 * - Android 10 and later: from the tree folder's MediaStore row, which
 *   [MediaStore.getMediaUri] finds and the tree's grant lets the app read.
 * - Android 7 to 9, which have no such call: from the storage provider's document ID,
 *   `<volume id>:<relative path>`, an undocumented shape, accepted only for a mounted volume.
 *   With the storage permission, the folder it names must also exist and hold the same
 *   entries as the tree.
 * - `null` when the location can't be confirmed, such as for a provider that isn't the
 *   device's storage, or a folder MediaStore doesn't know.
 */
internal class TreeLocationResolver(
    private val context: Context,
    private val storageManager: StorageManager,
    private val volumeRoots: VolumeRootResolver,
    private val sdkInt: Int = Build.VERSION.SDK_INT,
) {
    /**
     * The location of [treeUri], or `null` when it can't be confirmed.
     *
     * Blocks while providers are asked; must be called off the main thread.
     */
    fun resolve(treeUri: Uri): TreeLocation? {
        if (treeUri.authority != EXTERNAL_STORAGE_AUTHORITY) {
            return null
        }
        return try {
            if (sdkInt >= Build.VERSION_CODES.Q) {
                resolveFromMediaStore(treeUri)
            } else {
                resolveFromDocumentId(treeUri)
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "Failed to resolve the location of $treeUri", e)
            null
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Failed to resolve the location of $treeUri", e)
            null
        } catch (e: UnsupportedOperationException) {
            Log.w(TAG, "Failed to resolve the location of $treeUri", e)
            null
        }
    }

    /** Reads the location from the tree folder's MediaStore row. */
    @SuppressLint("NewApi")
    private fun resolveFromMediaStore(treeUri: Uri): TreeLocation? {
        val rootUri = DocumentsContract.buildDocumentUriUsingTree(
            treeUri,
            DocumentsContract.getTreeDocumentId(treeUri),
        )
        val mediaUri = MediaStore.getMediaUri(context, rootUri) ?: return null
        val projection = arrayOf(
            MediaStore.MediaColumns.VOLUME_NAME,
            MediaStore.MediaColumns.RELATIVE_PATH,
            MediaStore.MediaColumns.DISPLAY_NAME,
        )
        return context.contentResolver.query(mediaUri, projection, null, null, null)?.use { cursor ->
            if (!cursor.moveToFirst()) {
                return null
            }
            val volumeName = cursor.getString(0) ?: return null
            val parentPath = cursor.getString(1)
            val name = cursor.getString(2) ?: return null
            val volumeId = getVolumeId(volumeName) ?: return null
            TreeLocation(volumeId = volumeId, relativePath = joinPath(parentPath, name))
        }
    }

    /**
     * Reads the location from the tree's document ID, accepted only for a mounted volume, and
     * with the storage permission only when the folder it names holds the tree's entries.
     */
    private fun resolveFromDocumentId(treeUri: Uri): TreeLocation? {
        val documentId = DocumentsContract.getTreeDocumentId(treeUri)
        val volumePart = documentId.substringBefore(':', missingDelimiterValue = "")
        val volume = findVolume(volumePart) ?: return null
        val volumeId = if (volume.isPrimary) PRIMARY_VOLUME_ID else volume.uuid ?: return null
        val location = TreeLocation(volumeId = volumeId, relativePath = documentId.substringAfter(':'))

        if (!hasStoragePermission()) {
            // Nothing more can be checked without it.
            return location
        }
        val volumeRoot = volumeRoots.resolve(volume) ?: return location
        val folderEntries = File(volumeRoot, location.relativePath).list()?.toSet() ?: return null
        val treeEntries = listTreeEntries(treeUri, documentId) ?: return null
        return if (folderEntries == treeEntries) location else null
    }

    /**
     * The volume whose ID, as the storage provider writes it, is [volumePart]: `primary`, or the
     * volume's UUID.
     */
    private fun findVolume(volumePart: String): StorageVolume? {
        if (volumePart.isEmpty()) {
            return null
        }
        return storageManager.storageVolumes.firstOrNull { volume ->
            if (volumePart == PRIMARY_VOLUME_ID) {
                volume.isPrimary
            } else {
                volume.uuid.equals(volumePart, ignoreCase = true)
            }
        }
    }

    /**
     * The volume ID for MediaStore's [volumeName]: `primary` for the primary volume, otherwise
     * the volume's UUID as the system writes it, since MediaStore lower-cases it.
     */
    private fun getVolumeId(volumeName: String): String? {
        if (volumeName == MediaStore.VOLUME_EXTERNAL_PRIMARY) {
            return PRIMARY_VOLUME_ID
        }
        return storageManager.storageVolumes
            .firstOrNull { it.uuid.equals(volumeName, ignoreCase = true) }
            ?.uuid
    }

    private fun hasStoragePermission(): Boolean =
        context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) ==
            PackageManager.PERMISSION_GRANTED

    /** The names of the tree's top-level entries, or `null` if they can't be listed. */
    private fun listTreeEntries(treeUri: Uri, documentId: String): Set<String>? {
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, documentId)
        return context.contentResolver.query(
            childrenUri,
            arrayOf(Document.COLUMN_DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            buildSet {
                while (cursor.moveToNext()) {
                    cursor.getString(0)?.let(::add)
                }
            }
        }
    }

    /**
     * [name] under [parentPath], as MediaStore writes it: `DCIM/`, `/` for the volume's top
     * level, or `null` for none.
     */
    private fun joinPath(parentPath: String?, name: String): String {
        val parent = parentPath?.trim('/').orEmpty()
        return if (parent.isEmpty()) name else "$parent/$name"
    }

    private companion object {
        private const val TAG = "TreeLocationResolver"
        private const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"
        private const val PRIMARY_VOLUME_ID = "primary"
    }
}
