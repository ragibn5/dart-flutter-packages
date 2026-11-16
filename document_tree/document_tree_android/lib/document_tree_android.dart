/// Reads and writes folders the user picks, through Android's Storage Access
/// Framework.
library;

import 'package:document_tree_android/document_tree_android_platform_interface.dart';
import 'package:document_tree_android/src/exceptions/document_exceptions.dart';
import 'package:document_tree_android/src/exceptions/tree_pick_exception.dart';
import 'package:document_tree_android/src/exceptions/tree_request_exception.dart';
import 'package:document_tree_android/src/models/copy_document_request.dart';
import 'package:document_tree_android/src/models/document_info.dart';
import 'package:document_tree_android/src/models/document_tree.dart';
import 'package:document_tree_android/src/models/list_documents_request.dart';
import 'package:document_tree_android/src/models/pick_tree_request.dart';

export 'src/exceptions/document_exceptions.dart'
    hide DocumentQueryExceptionMapper, DocumentWriteExceptionMapper;
export 'src/exceptions/tree_pick_exception.dart' hide TreePickExceptionMapper;
export 'src/exceptions/tree_request_exception.dart'
    hide TreeRequestExceptionMapper;
export 'src/models/copy_document_request.dart';
export 'src/models/document_info.dart';
export 'src/models/document_tree.dart';
export 'src/models/list_documents_request.dart';
export 'src/models/pick_tree_request.dart';
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

  /// Copies the file [request] points to into its tree.
  ///
  /// A file the copy created is deleted again if the copy fails. A file it
  /// overwrote can't be restored: it's left with what was copied so far.
  ///
  /// Returns: the copy.
  ///
  /// Throws: a [DocumentWriteException] if the file can't be copied. See
  /// [CopyDocumentRequest] for more info.
  Future<DocumentInfo> copyDocument(CopyDocumentRequest request) {
    return DocumentTreeAndroidPlatform.instance.copyDocument(request);
  }
}
