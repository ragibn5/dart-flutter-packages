import 'package:document_tree_android/document_tree_android.dart';
import 'package:document_tree_android/document_tree_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class DocumentTreeAndroidPlatform extends PlatformInterface {
  static final Object _token = Object();
  static DocumentTreeAndroidPlatform _instance =
      MethodChannelDocumentTreeAndroid();

  /// Constructs a DocumentTreeAndroidPlatform.
  DocumentTreeAndroidPlatform() : super(token: _token);

  /// The default instance of [DocumentTreeAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelDocumentTreeAndroid].
  static DocumentTreeAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DocumentTreeAndroidPlatform] when
  /// they register themselves.
  static set instance(DocumentTreeAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Lets the user pick a folder, and persists the app's access to it.
  ///
  /// See [PickTreeRequest] for more info.
  Future<DocumentTree?> pickTree(PickTreeRequest request) {
    throw UnimplementedError('pickTree() has not been implemented.');
  }

  /// Describes the tree [treeUri] points to.
  ///
  /// See [DocumentTree] for more info.
  Future<DocumentTree?> getTree(String treeUri) {
    throw UnimplementedError('getTree() has not been implemented.');
  }

  /// Drops the app's access to the tree [treeUri] points to.
  Future<void> releaseTree(String treeUri) {
    throw UnimplementedError('releaseTree() has not been implemented.');
  }

  /// Lists the documents in the folder [request] points to.
  ///
  /// See [ListDocumentsRequest] for more info.
  Future<List<DocumentInfo>> listDocuments(ListDocumentsRequest request) {
    throw UnimplementedError('listDocuments() has not been implemented.');
  }
}
