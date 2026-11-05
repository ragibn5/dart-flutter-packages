package com.ragibn5.document.tree.document_tree_android.features.tree.services

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import com.ragibn5.document.tree.document_tree_android.exceptions.DocumentTreeException
import com.ragibn5.document.tree.document_tree_android.features.tree.constants.TreePickExceptionCodes
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CompletableDeferred

/**
 * Shows the system's folder picker from the current activity, and hands back
 * its result.
 *
 * Note:
 * Must be attached to every activity the plugin is attached to, including the
 * one recreated after a configuration change: the picker's result is
 * delivered to that one.
 */
internal class TreePickerLauncher : PluginRegistry.ActivityResultListener {
    private var binding: ActivityPluginBinding? = null
    private var pendingResult: CompletableDeferred<Intent?>? = null

    fun attach(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(this)
    }

    fun detach() {
        binding?.removeActivityResultListener(this)
        binding = null
    }

    /**
     * Ends the picking in progress, if any, as if the user cancelled it.
     */
    fun cancel() {
        pendingResult?.complete(null)
        pendingResult = null
    }

    /**
     * Shows the picker, and waits for the user to pick a folder.
     *
     * Must be called on the main thread.
     *
     * @param initialUri where the picker starts, or `null` for the system's default.
     * @return the picker's result, or `null` if the user cancelled.
     * @throws DocumentTreeException with a [TreePickExceptionCodes] code.
     */
    suspend fun launch(initialUri: Uri?): Intent? {
        val activity = binding?.activity
            ?: throw DocumentTreeException(
                TreePickExceptionCodes.NO_ACTIVITY,
                "No activity to show the picker from; the app must be in the foreground"
            )
        if (pendingResult != null) {
            throw DocumentTreeException(
                TreePickExceptionCodes.PICKER_ALREADY_OPEN,
                "The picker is already open"
            )
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        if (initialUri != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
        }

        val result = CompletableDeferred<Intent?>()
        pendingResult = result
        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
            return result.await()
        } catch (e: ActivityNotFoundException) {
            throw DocumentTreeException(
                TreePickExceptionCodes.PICKER_UNAVAILABLE,
                e.message ?: "The device has no folder picker",
                cause = e
            )
        } finally {
            if (pendingResult === result) {
                pendingResult = null
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) {
            return false
        }

        pendingResult?.complete(if (resultCode == Activity.RESULT_OK) data else null)
        pendingResult = null
        return true
    }

    private companion object {
        private const val REQUEST_CODE = 0x7EE5
    }
}
