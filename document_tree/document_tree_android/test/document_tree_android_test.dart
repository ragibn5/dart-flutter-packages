import 'package:document_tree_android/document_tree_android.dart';
import 'package:document_tree_android/document_tree_android_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'helpers/fixtures.dart';

class _MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements DocumentTreeAndroidPlatform {}

void main() {
  late DocumentTreeAndroidPlatform original;
  late _MockPlatform platform;
  final sut = DocumentTreeAndroid();

  setUp(() {
    original = DocumentTreeAndroidPlatform.instance;
    platform = _MockPlatform();
    DocumentTreeAndroidPlatform.instance = platform;
  });

  tearDown(() => DocumentTreeAndroidPlatform.instance = original);

  test('pickTreeShouldReturnWhatPlatformReturnsForRequest', () async {
    when(() => platform.pickTree(pickRequest)).thenAnswer((_) async => tree);

    expect(await sut.pickTree(pickRequest), tree);
  });

  test('getTreeShouldReturnWhatPlatformReturnsForUri', () async {
    when(() => platform.getTree(treeUri)).thenAnswer((_) async => tree);

    expect(await sut.getTree(treeUri), tree);
  });

  test('releaseTreeShouldReleaseThroughPlatform', () async {
    when(() => platform.releaseTree(treeUri)).thenAnswer((_) async {});

    await sut.releaseTree(treeUri);

    verify(() => platform.releaseTree(treeUri)).called(1);
  });

  test('listDocumentsShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.listDocuments(listRequest),
    ).thenAnswer((_) async => [document]);

    expect(await sut.listDocuments(listRequest), [document]);
  });

  test('copyDocumentShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.copyDocument(copyRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.copyDocument(copyRequest), document);
  });

  test('getDocumentShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.getDocument(getRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.getDocument(getRequest), document);
  });

  test('createDirectoryShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.createDirectory(createDirectoryRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.createDirectory(createDirectoryRequest), document);
  });

  test('createDocumentShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.createDocument(createDocumentRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.createDocument(createDocumentRequest), document);
  });

  test('renameDocumentShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.renameDocument(renameRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.renameDocument(renameRequest), document);
  });

  test('moveDocumentShouldReturnWhatPlatformReturnsForRequest', () async {
    when(
      () => platform.moveDocument(moveRequest),
    ).thenAnswer((_) async => document);

    expect(await sut.moveDocument(moveRequest), document);
  });

  test('deleteDocumentShouldDeleteThroughPlatform', () async {
    when(() => platform.deleteDocument(deleteRequest)).thenAnswer((_) async {});

    await sut.deleteDocument(deleteRequest);

    verify(() => platform.deleteDocument(deleteRequest)).called(1);
  });
}
