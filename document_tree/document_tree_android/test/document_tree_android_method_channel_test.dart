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

  group('getDocument', () {
    test('getDocumentShouldSendRequestAsJsonToGetDocument', () async {
      replyWith(null);

      await sut.getDocument(getRequest);

      expect(calls.single.method, 'getDocument');
      expect(jsonDecode(calls.single.arguments as String), getRequest.toJson());
    });

    test('getDocumentShouldReturnDecodedDocumentIfOneIsAtPath', () async {
      replyWith(jsonEncode(document.toJson()));

      expect(await sut.getDocument(getRequest), document);
    });

    test('getDocumentShouldReturnNullIfNoneIsAtPath', () async {
      replyWith(null);

      expect(await sut.getDocument(getRequest), isNull);
    });

    test('getDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentQueryMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'tree_access_lost'));

      expect(sut.getDocument(getRequest), throwsA(isA<_MappedException>()));
    });
  });

  group('createDirectory', () {
    test('createDirectoryShouldSendRequestAsJsonToCreateDirectory', () async {
      replyWith(jsonEncode(document.toJson()));

      await sut.createDirectory(createDirectoryRequest);

      expect(calls.single.method, 'createDirectory');
      expect(
        jsonDecode(calls.single.arguments as String),
        createDirectoryRequest.toJson(),
      );
    });

    test(
      'createDirectoryShouldReturnDecodedDocumentIfPlatformReplies',
      () async {
        replyWith(jsonEncode(document.toJson()));

        expect(await sut.createDirectory(createDirectoryRequest), document);
      },
    );

    test('createDirectoryShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'already_exists'));

      expect(
        sut.createDirectory(createDirectoryRequest),
        throwsA(isA<_MappedException>()),
      );
    });
  });

  group('createDocument', () {
    test(
      'createDocumentShouldSendRequestAsJsonAndBytesApartToCreateDocument',
      () async {
        replyWith(jsonEncode(document.toJson()));

        await sut.createDocument(createDocumentRequest);

        final arguments = calls.single.arguments as Map<Object?, Object?>;
        expect(calls.single.method, 'createDocument');
        expect(
          jsonDecode(arguments['request']! as String),
          createDocumentRequest.toJson(),
        );
        expect(arguments['bytes'], createDocumentRequest.bytes);
      },
    );

    test(
      'createDocumentShouldReturnDecodedDocumentIfPlatformReplies',
      () async {
        replyWith(jsonEncode(document.toJson()));

        expect(await sut.createDocument(createDocumentRequest), document);
      },
    );

    test('createDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'already_exists'));

      expect(
        sut.createDocument(createDocumentRequest),
        throwsA(isA<_MappedException>()),
      );
    });
  });

  group('copyDocument', () {
    test('copyDocumentShouldSendRequestAsJsonToCopyDocument', () async {
      replyWith(jsonEncode(copiedDocument.toJson()));

      await sut.copyDocument(copyRequest);

      expect(calls.single.method, 'copyDocument');
      expect(
        jsonDecode(calls.single.arguments as String),
        copyRequest.toJson(),
      );
    });

    test('copyDocumentShouldReturnDecodedCopyIfPlatformReplies', () async {
      replyWith(jsonEncode(copiedDocument.toJson()));

      expect(await sut.copyDocument(copyRequest), copiedDocument);
    });

    test('copyDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'not_enough_space'));

      expect(sut.copyDocument(copyRequest), throwsA(isA<_MappedException>()));
    });
  });

  group('renameDocument', () {
    test('renameDocumentShouldSendRequestAsJsonToRenameDocument', () async {
      replyWith(jsonEncode(document.toJson()));

      await sut.renameDocument(renameRequest);

      expect(calls.single.method, 'renameDocument');
      expect(
        jsonDecode(calls.single.arguments as String),
        renameRequest.toJson(),
      );
    });

    test(
      'renameDocumentShouldReturnDecodedDocumentIfPlatformReplies',
      () async {
        replyWith(jsonEncode(document.toJson()));

        expect(await sut.renameDocument(renameRequest), document);
      },
    );

    test('renameDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'already_exists'));

      expect(
        sut.renameDocument(renameRequest),
        throwsA(isA<_MappedException>()),
      );
    });
  });

  group('moveDocument', () {
    test('moveDocumentShouldSendRequestAsJsonToMoveDocument', () async {
      replyWith(jsonEncode(document.toJson()));

      await sut.moveDocument(moveRequest);

      expect(calls.single.method, 'moveDocument');
      expect(
        jsonDecode(calls.single.arguments as String),
        moveRequest.toJson(),
      );
    });

    test('moveDocumentShouldReturnDecodedDocumentIfPlatformReplies', () async {
      replyWith(jsonEncode(document.toJson()));

      expect(await sut.moveDocument(moveRequest), document);
    });

    test('moveDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'unsupported_operation'));

      expect(sut.moveDocument(moveRequest), throwsA(isA<_MappedException>()));
    });
  });

  group('deleteDocument', () {
    test('deleteDocumentShouldSendRequestAsJsonToDeleteDocument', () async {
      replyWith(null);

      await sut.deleteDocument(deleteRequest);

      expect(calls.single.method, 'deleteDocument');
      expect(
        jsonDecode(calls.single.arguments as String),
        deleteRequest.toJson(),
      );
    });

    test('deleteDocumentShouldThrowMappedExceptionIfPlatformFails', () {
      when(
        () => documentWriteMapper.map(any()),
      ).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'not_found'));

      expect(
        sut.deleteDocument(deleteRequest),
        throwsA(isA<_MappedException>()),
      );
    });
  });
}
