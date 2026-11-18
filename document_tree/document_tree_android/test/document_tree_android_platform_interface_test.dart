import 'package:document_tree_android/document_tree_android_method_channel.dart';
import 'package:document_tree_android/document_tree_android_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'helpers/fixtures.dart';

/// Extends the platform interface without overriding anything.
class _BarePlatform extends DocumentTreeAndroidPlatform {}

/// Implements the platform interface without its token.
class _TokenlessPlatform implements DocumentTreeAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Implements the platform interface the way test mocks do.
class _MockPlatform
    with MockPlatformInterfaceMixin
    implements DocumentTreeAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final platform = _BarePlatform();

  group('instance', () {
    late DocumentTreeAndroidPlatform original;

    setUp(() => original = DocumentTreeAndroidPlatform.instance);

    tearDown(() => DocumentTreeAndroidPlatform.instance = original);

    test('instanceShouldBeMethodChannelImplementationByDefault', () {
      expect(
        DocumentTreeAndroidPlatform.instance,
        isA<MethodChannelDocumentTreeAndroid>(),
      );
    });

    test('instanceShouldBeReplacedIfSetToImplementationWithToken', () {
      final mock = _MockPlatform();

      DocumentTreeAndroidPlatform.instance = mock;

      expect(DocumentTreeAndroidPlatform.instance, same(mock));
    });

    test('instanceShouldThrowAssertionErrorIfSetWithoutToken', () {
      expect(
        () => DocumentTreeAndroidPlatform.instance = _TokenlessPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('pickTreeShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.pickTree(pickRequest), throwsUnimplementedError);
  });

  test('getTreeShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.getTree(treeUri), throwsUnimplementedError);
  });

  test('releaseTreeShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.releaseTree(treeUri), throwsUnimplementedError);
  });

  test('listDocumentsShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.listDocuments(listRequest), throwsUnimplementedError);
  });

  test('copyDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.copyDocument(copyRequest), throwsUnimplementedError);
  });

  test('getDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.getDocument(getRequest), throwsUnimplementedError);
  });

  test('createDirectoryShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.createDirectory(createDirectoryRequest),
      throwsUnimplementedError,
    );
  });

  test('createDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.createDocument(createDocumentRequest),
      throwsUnimplementedError,
    );
  });

  test('renameDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.renameDocument(renameRequest),
      throwsUnimplementedError,
    );
  });

  test('moveDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(() => platform.moveDocument(moveRequest), throwsUnimplementedError);
  });

  test('deleteDocumentShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.deleteDocument(deleteRequest),
      throwsUnimplementedError,
    );
  });
}
