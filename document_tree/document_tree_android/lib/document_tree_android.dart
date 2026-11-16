/// Reads and writes folders the user picks, through Android's Storage Access
/// Framework.
library;

import 'package:document_tree_android/document_tree_android_platform_interface.dart';
import 'package:document_tree_android/src/exceptions/document_exceptions.dart';
import 'package:document_tree_android/src/exceptions/tree_pick_exception.dart';
import 'package:document_tree_android/src/exceptions/tree_request_exception.dart';
import 'package:document_tree_android/src/models/copy_document_request.dart';
import 'package:document_tree_android/src/models/create_directory_request.dart';
import 'package:document_tree_android/src/models/delete_document_request.dart';
import 'package:document_tree_android/src/models/document_info.dart';
import 'package:document_tree_android/src/models/document_tree.dart';
import 'package:document_tree_android/src/models/get_document_request.dart';
import 'package:document_tree_android/src/models/list_documents_request.dart';
import 'package:document_tree_android/src/models/move_document_request.dart';
import 'package:document_tree_android/src/models/pick_tree_request.dart';
import 'package:document_tree_android/src/models/rename_document_request.dart';

export 'src/exceptions/document_exceptions.dart'
    hide DocumentQueryExceptionMapper, DocumentWriteExceptionMapper;
export 'src/exceptions/tree_pick_exception.dart' hide TreePickExceptionMapper;
export 'src/exceptions/tree_request_exception.dart'
    hide TreeRequestExceptionMapper;
export 'src/models/copy_document_request.dart';
export 'src/models/create_directory_request.dart';
export 'src/models/delete_document_request.dart';
export 'src/models/document_info.dart';
export 'src/models/document_tree.dart';
export 'src/models/get_document_request.dart';
export 'src/models/list_documents_request.dart';
export 'src/models/move_document_request.dart';
export 'src/models/pick_tree_request.dart';
export 'src/models/rename_document_request.dart';
export 'src/models/tree_location.dart';

class DocumentTreeAndroid {
  /// Lets the user pick a folder, and persists the app's access to it.
  ///
  /// Returns: the picked tree, or `null` if the user cancels.
  ///
  /// Throws: a [TreePickException] if the picker can't be shown. See
  /// [PickTreeRequest] for more info.
  Future<DocumentTree?> pickTree(PickTreeRequest request) {
    return DocumentTreeAndroidPlatform.instance.pickTree(request);
  }

  /// Describes the tree [treeUri] points to.
  ///
  /// Returns: the tree, or `null` if the app holds no grant on it, or it
  /// can't be reached, such as when it was deleted or its volume was removed.
  ///
  /// Throws: a [TreeRequestException] if [treeUri] isn't a tree's URI.
  Future<DocumentTree?> getTree(String treeUri) {
    return DocumentTreeAndroidPlatform.instance.getTree(treeUri);
  }

  /// Drops the app's access to the tree [treeUri] points to.
  ///
  /// Does nothing if the app holds no grant on it.
  ///
  /// Throws: a [TreeRequestException] if [treeUri] isn't a tree's URI.
  Future<void> releaseTree(String treeUri) {
    return DocumentTreeAndroidPlatform.instance.releaseTree(treeUri);
  }

  /// Lists the documents in the folder [request] points to.
  ///
  /// Returns: its files and folders, with their subfolders' too if
  /// [ListDocumentsRequest.recursive], in no particular order.
  ///
  /// Throws: a [DocumentQueryException] if the tree or folder can't be
  /// listed. See [ListDocumentsRequest] for more info.
  Future<List<DocumentInfo>> listDocuments(ListDocumentsRequest request) {
    return DocumentTreeAndroidPlatform.instance.listDocuments(request);
  }

  /// Describes the document [request] points to: whether it exists, and if
  /// so, whether it's a file or a folder.
  ///
  /// Returns: the document, or `null` if there's none at its path.
  ///
  /// Throws: a [DocumentQueryException] if the tree can't be read. See
  /// [GetDocumentRequest] for more info.
  Future<DocumentInfo?> getDocument(GetDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.getDocument(request);
  }

  /// Creates the folder [request] points to, in the existing folder holding
  /// it.
  ///
  /// Fails with a [DocumentAlreadyExistsException] if a document already has
  /// its name.
  ///
  /// Returns: the created folder.
  ///
  /// Throws: a [DocumentWriteException] if it can't be created. See
  /// [CreateDirectoryRequest] for more info.
  Future<DocumentInfo> createDirectory(CreateDirectoryRequest request) {
    return DocumentTreeAndroidPlatform.instance.createDirectory(request);
  }

  /// Copies the file [request] points to into its tree, as a new file in an
  /// existing folder.
  ///
  /// Fails with a [DocumentAlreadyExistsException] if a document already has
  /// its name. The copy is deleted again if it fails, so it leaves nothing
  /// behind.
  ///
  /// Returns: the copy.
  ///
  /// Throws: a [DocumentWriteException] if the file can't be copied. See
  /// [CopyDocumentRequest] for more info.
  Future<DocumentInfo> copyDocument(CopyDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.copyDocument(request);
  }

  /// Renames the document [request] points to, in its folder.
  ///
  /// Fails with a [DocumentAlreadyExistsException] if a document already has
  /// that name. Whether a name differing only in case counts is the
  /// provider's call: the rename then fails rather than taking another name.
  /// On local storage, no data is copied.
  ///
  /// Returns: the renamed document.
  ///
  /// Throws: a [DocumentWriteException] if it can't be renamed. See
  /// [RenameDocumentRequest] for more info.
  Future<DocumentInfo> renameDocument(RenameDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.renameDocument(request);
  }

  /// Moves the document [request] points to into another existing folder of
  /// its tree, keeping its name.
  ///
  /// Fails with a [DocumentAlreadyExistsException] if a document there already
  /// has its name. Whether a name differing only in case counts is the
  /// provider's call. On local storage, no data is copied.
  ///
  /// Returns: the moved document.
  ///
  /// Throws: a [DocumentWriteException] if it can't be moved. See
  /// [MoveDocumentRequest] for more info.
  Future<DocumentInfo> moveDocument(MoveDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.moveDocument(request);
  }

  /// Deletes the document [request] points to: a file, or a folder with
  /// everything in it.
  ///
  /// A folder's deletion that fails partway may leave some of what it held.
  ///
  /// Throws: a [DocumentWriteException] if it can't be deleted. See
  /// [DeleteDocumentRequest] for more info.
  Future<void> deleteDocument(DeleteDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.deleteDocument(request);
  }
}
