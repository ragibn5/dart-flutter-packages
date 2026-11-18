package com.ragibn5.document.tree.document_tree_android

import android.content.Context
import androidx.annotation.VisibleForTesting
import com.ragibn5.document.tree.document_tree_android.features.document.di.DirectoryCreateServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentCopyServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentCreateServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentDeleteServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentGetServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentListServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentMoveServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.di.DocumentRenameServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.CopyDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.CreateDirectoryRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.CreateDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.DeleteDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.GetDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.ListDocumentsRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.MoveDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.handlers.RenameDocumentRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.document.services.DirectoryCreateService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCopyService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentCreateService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentDeleteService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentGetService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentListService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentMoveService
import com.ragibn5.document.tree.document_tree_android.features.document.services.DocumentRenameService
import com.ragibn5.document.tree.document_tree_android.features.tree.di.DocumentTreeServiceFactory
import com.ragibn5.document.tree.document_tree_android.features.tree.handlers.GetTreeRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.tree.handlers.PickTreeRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.tree.handlers.ReleaseTreeRequestHandler
import com.ragibn5.document.tree.document_tree_android.features.tree.services.DocumentTreeService
import com.ragibn5.document.tree.document_tree_android.features.tree.services.TreePickerLauncher
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

public class DocumentTreeAndroidPlugin : FlutterPlugin, ActivityAware {
    private lateinit var mainChannel: MethodChannel
    private lateinit var requestDispatcher: MethodCallDispatcher
    private lateinit var documentTreeService: DocumentTreeService
    private lateinit var documentListService: DocumentListService
    private lateinit var documentGetService: DocumentGetService
    private lateinit var directoryCreateService: DirectoryCreateService
    private lateinit var documentCreateService: DocumentCreateService
    private lateinit var documentCopyService: DocumentCopyService
    private lateinit var documentRenameService: DocumentRenameService
    private lateinit var documentMoveService: DocumentMoveService
    private lateinit var documentDeleteService: DocumentDeleteService

    /**
     * Shows the folder picker from the activity the plugin is attached to.
     */
    private val treePickerLauncher = TreePickerLauncher()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        attach(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger,
        )
    }

    /**
     * Serves the tree and document services over [binaryMessenger].
     *
     * Separate from [onAttachedToEngine] so the wiring can be exercised without
     * a device.
     */
    @VisibleForTesting
    internal fun attach(appContext: Context, binaryMessenger: BinaryMessenger) {
        // Services
        documentTreeService = DocumentTreeServiceFactory.create(appContext, treePickerLauncher)
        documentListService = DocumentListServiceFactory.create(appContext)
        documentGetService = DocumentGetServiceFactory.create(appContext)
        directoryCreateService = DirectoryCreateServiceFactory.create(appContext)
        documentCreateService = DocumentCreateServiceFactory.create(appContext)
        documentCopyService = DocumentCopyServiceFactory.create(appContext)
        documentRenameService = DocumentRenameServiceFactory.create(appContext)
        documentMoveService = DocumentMoveServiceFactory.create(appContext)
        documentDeleteService = DocumentDeleteServiceFactory.create(appContext)

        // Main request dispatcher
        requestDispatcher = MethodCallDispatcher(
            listOf(
                PickTreeRequestHandler(documentTreeService),
                GetTreeRequestHandler(documentTreeService),
                ReleaseTreeRequestHandler(documentTreeService),
                ListDocumentsRequestHandler(documentListService),
                GetDocumentRequestHandler(documentGetService),
                CreateDirectoryRequestHandler(directoryCreateService),
                CreateDocumentRequestHandler(documentCreateService),
                CopyDocumentRequestHandler(documentCopyService),
                RenameDocumentRequestHandler(documentRenameService),
                MoveDocumentRequestHandler(documentMoveService),
                DeleteDocumentRequestHandler(documentDeleteService),
            ),
        )

        // Channels
        mainChannel = MethodChannel(binaryMessenger, MAIN_CHANNEL_NAME)
            .apply { setMethodCallHandler(requestDispatcher) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Close the channels
        mainChannel.setMethodCallHandler(null)

        // Close the main dispatcher
        requestDispatcher.dispose()

        // End the picking in progress
        treePickerLauncher.cancel()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        treePickerLauncher.attach(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // The picker stays open; its result goes to the recreated activity.
        treePickerLauncher.detach()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        treePickerLauncher.attach(binding)
    }

    override fun onDetachedFromActivity() {
        treePickerLauncher.detach()
        treePickerLauncher.cancel()
    }

    private companion object {
        private const val MAIN_CHANNEL_NAME = "document_tree_android"
    }
}
