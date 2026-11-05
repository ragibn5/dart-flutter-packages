import 'dart:convert';

import 'package:document_tree_android/document_tree_android_platform_interface.dart';
import 'package:document_tree_android/src/exceptions/document_exceptions.dart';
import 'package:document_tree_android/src/exceptions/tree_pick_exception.dart';
import 'package:document_tree_android/src/exceptions/tree_request_exception.dart';
import 'package:document_tree_android/src/models/copy_document_request.dart';
import 'package:document_tree_android/src/models/document_info.dart';
import 'package:document_tree_android/src/models/document_tree.dart';
import 'package:document_tree_android/src/models/list_documents_request.dart';
import 'package:document_tree_android/src/models/pick_tree_request.dart';
import 'package:document_tree_android/src/utils/json_decoder.dart';
import 'package:document_tree_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [DocumentTreeAndroidPlatform] that uses method channels.
class MethodChannelDocumentTreeAndroid extends DocumentTreeAndroidPlatform {
  static const CHANNEL_NAME = 'document_tree_android';

  /// Main channel.
  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  final TreePickExceptionMapper _treePickExceptionMapper;
  final TreeRequestExceptionMapper _treeRequestExceptionMapper;
  final DocumentQueryExceptionMapper _documentQueryExceptionMapper;
  final DocumentWriteExceptionMapper _documentWriteExceptionMapper;

  MethodChannelDocumentTreeAndroid({
    @visibleForTesting
    TreePickExceptionMapper treePickExceptionMapper =
        const TreePickExceptionMapper(),
    @visibleForTesting
    TreeRequestExceptionMapper treeRequestExceptionMapper =
        const TreeRequestExceptionMapper(),
    @visibleForTesting
    DocumentQueryExceptionMapper documentQueryExceptionMapper =
        const DocumentQueryExceptionMapper(),
    @visibleForTesting
    DocumentWriteExceptionMapper documentWriteExceptionMapper =
        const DocumentWriteExceptionMapper(),
  }) : _treePickExceptionMapper = treePickExceptionMapper,
       _treeRequestExceptionMapper = treeRequestExceptionMapper,
       _documentQueryExceptionMapper = documentQueryExceptionMapper,
       _documentWriteExceptionMapper = documentWriteExceptionMapper;

  @override
  Future<DocumentTree?> pickTree(PickTreeRequest request) async {
    final result = await guardPlatformCall(
      _treePickExceptionMapper,
      () => methodChannel.invokeMethod<String>(
        'pickTree',
        jsonEncode(request.toJson()),
      ),
    );

    return result == null
        ? null
        : decodeJsonObject(result, DocumentTree.fromJson);
  }

  @override
  Future<DocumentTree?> getTree(String treeUri) async {
    final result = await guardPlatformCall(
      _treeRequestExceptionMapper,
      () => methodChannel.invokeMethod<String>('getTree', treeUri),
    );

    return result == null
        ? null
        : decodeJsonObject(result, DocumentTree.fromJson);
  }

  @override
  Future<void> releaseTree(String treeUri) {
    return guardPlatformCall(
      _treeRequestExceptionMapper,
      () => methodChannel.invokeMethod<void>('releaseTree', treeUri),
    );
  }

  @override
  Future<List<DocumentInfo>> listDocuments(ListDocumentsRequest request) async {
    final result = await guardPlatformCall(
      _documentQueryExceptionMapper,
      () => methodChannel.invokeMethod<String>(
        'listDocuments',
        jsonEncode(request.toJson()),
      ),
    );

    return decodeJsonListInBackground(result!, DocumentInfo.fromJson);
  }

  @override
  Future<DocumentInfo> copyDocument(CopyDocumentRequest request) async {
    final result = await guardPlatformCall(
      _documentWriteExceptionMapper,
      () => methodChannel.invokeMethod<String>(
        'copyDocument',
        jsonEncode(request.toJson()),
      ),
    );

    return decodeJsonObject(result!, DocumentInfo.fromJson);
  }
}
