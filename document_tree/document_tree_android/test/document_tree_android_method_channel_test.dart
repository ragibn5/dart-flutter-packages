import 'dart:convert';

import 'package:document_tree_android/document_tree_android_method_channel.dart';
import 'package:document_tree_android/src/exceptions/document_exceptions.dart';
import 'package:document_tree_android/src/exceptions/tree_pick_exception.dart';
import 'package:document_tree_android/src/exceptions/tree_request_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fixtures.dart';

class _MockTreePickMapper extends Mock implements TreePickExceptionMapper {}

class _MockTreeRequestMapper extends Mock
    implements TreeRequestExceptionMapper {}

class _MockDocumentQueryMapper extends Mock
    implements DocumentQueryExceptionMapper {}

class _MockDocumentWriteMapper extends Mock
    implements DocumentWriteExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelDocumentTreeAndroid.CHANNEL_NAME);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockTreePickMapper treePickMapper;
  late _MockTreeRequestMapper treeRequestMapper;
  late _MockDocumentQueryMapper documentQueryMapper;
  late _MockDocumentWriteMapper documentWriteMapper;
  late MethodChannelDocumentTreeAndroid sut;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Makes the platform side answer every call with [reply], or throw it when
  /// it's a [PlatformException].
  void replyWith(Object? reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (reply is PlatformException) {
        throw reply;
      }
      return reply;
    });
  }

  setUpAll(() {
    registerFallbackValue(PlatformException(code: 'fallback'));
  });

  setUp(() {
    treePickMapper = _MockTreePickMapper();
    treeRequestMapper = _MockTreeRequestMapper();
    documentQueryMapper = _MockDocumentQueryMapper();
    documentWriteMapper = _MockDocumentWriteMapper();
    calls = [];
    sut = MethodChannelDocumentTreeAndroid(
      treePickExceptionMapper: treePickMapper,
      treeRequestExceptionMapper: treeRequestMapper,
      documentQueryExceptionMapper: documentQueryMapper,
      documentWriteExceptionMapper: documentWriteMapper,
    );
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('pickTree', () {
    test('pickTreeShouldSendRequestAsJsonToPickTree', () async {
      replyWith(null);

      await sut.pickTree(pickRequest);

      expect(calls.single.method, 'pickTree');
      expect(
        jsonDecode(calls.single.arguments as String),
        pickRequest.toJson(),
      );
    });

    test('pickTreeShouldReturnDecodedTreeIfUserPicksOne', () async {
      replyWith(jsonEncode(tree.toJson()));

      expect(await sut.pickTree(pickRequest), tree);
    });

    test('pickTreeShouldReturnNullIfUserCancels', () async {
      replyWith(null);

      expect(await sut.pickTree(pickRequest), isNull);
    });

    test('pickTreeShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => treePickMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'picker_already_open'));

      expect(sut.pickTree(pickRequest), throwsA(isA<_MappedException>()));
    });
  });

  group('getTree', () {
    test('getTreeShouldReturnDecodedTreeIfPlatformReplies', () async {
      replyWith(jsonEncode(tree.toJson()));

      expect(await sut.getTree(treeUri), tree);
      expect(calls.single.method, 'getTree');
      expect(calls.single.arguments, treeUri);
    });

    test('getTreeShouldReturnNullIfTreeIsUnavailable', () async {
      replyWith(null);

      expect(await sut.getTree(treeUri), isNull);
    });

    test('getTreeShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => treeRequestMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'invalid_request'));

      expect(sut.getTree(treeUri), throwsA(isA<_MappedException>()));
    });
  });

  group('releaseTree', () {
    test('releaseTreeShouldSendUriToReleaseTree', () async {
      replyWith(null);

      await sut.releaseTree(treeUri);

      expect(calls.single.method, 'releaseTree');
      expect(calls.single.arguments, treeUri);
    });

    test('releaseTreeShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => treeRequestMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'invalid_request'));

      expect(sut.releaseTree(treeUri), throwsA(isA<_MappedException>()));
    });
  });

  group('listDocuments', () {
    test('listDocumentsShouldSendRequestAsJsonToListDocuments', () async {
      replyWith('[]');

      await sut.listDocuments(listRequest);

      expect(calls.single.method, 'listDocuments');
      expect(
        jsonDecode(calls.single.arguments as String),
        listRequest.toJson(),
      );
    });

    test(
      'listDocumentsShouldReturnDecodedDocumentsIfPlatformReplies',
      () async {
        replyWith(jsonEncode([document.toJson()]));

        expect(await sut.listDocuments(listRequest), [document]);
      },
    );

    test('listDocumentsShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentQueryMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'tree_access_lost'));

      expect(sut.listDocuments(listRequest), throwsA(isA<_MappedException>()));
    });
  });

  group('copyDocument', () {
    test('copyDocumentShouldSendRequestAsJsonToCopyDocument', () async {
      replyWith(jsonEncode(document.toJson()));

      await sut.copyDocument(copyRequest);

      expect(calls.single.method, 'copyDocument');
      expect(
        jsonDecode(calls.single.arguments as String),
        copyRequest.toJson(),
      );
    });

    test('copyDocumentShouldReturnDecodedCopyIfPlatformReplies', () async {
      replyWith(jsonEncode(document.toJson()));

      expect(await sut.copyDocument(copyRequest), document);
    });

    test('copyDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'not_enough_space'));

      expect(sut.copyDocument(copyRequest), throwsA(isA<_MappedException>()));
    });
  });
}
