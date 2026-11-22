import 'package:content_io_android/content_io_android.dart';
import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/io/reader/content_reader.dart';
import 'package:content_io_android/src/io/writer/content_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ContentIoAndroidPlatform {}

class _MockReader extends Mock implements ContentReader {}

class _MockWriter extends Mock implements ContentWriter {}

void main() {
  late ContentIoAndroidPlatform original;
  late _MockPlatform platform;
  final sut = ContentIoAndroid();

  setUp(() {
    original = ContentIoAndroidPlatform.instance;
    platform = _MockPlatform();
    ContentIoAndroidPlatform.instance = platform;
  });

  tearDown(() => ContentIoAndroidPlatform.instance = original);

  test('openReadSessionShouldReturnWhatPlatformReturnsForRequest', () async {
    const request = OpenReadRequest(uri: 'content://media/1');
    final session = ContentReadSession(reader: _MockReader());
    when(
      () => platform.openReadSession(request),
    ).thenAnswer((_) async => session);

    expect(await sut.openReadSession(request), same(session));
  });

  test(
    'openThumbnailReadSessionShouldReturnWhatPlatformReturnsForRequest',
    () async {
      const request = OpenThumbnailReadRequest(
        uri: 'content://media/1',
        size: ThumbnailSize(width: 256, height: 256),
      );
      final session = ContentReadSession(reader: _MockReader());
      when(
        () => platform.openThumbnailReadSession(request),
      ).thenAnswer((_) async => session);

      expect(await sut.openThumbnailReadSession(request), same(session));
    },
  );

  test('openWriteSessionShouldReturnWhatPlatformReturnsForRequest', () async {
    const request = OpenWriteRequest(uri: 'content://media/1');
    final session = ContentWriteSession(writer: _MockWriter());
    when(
      () => platform.openWriteSession(request),
    ).thenAnswer((_) async => session);

    expect(await sut.openWriteSession(request), same(session));
  });

  test('hashContentShouldReturnWhatPlatformReturnsForRequest', () async {
    const request = HashContentRequest(uri: 'content://media/1');
    const hash = ContentHash(
      algorithm: ContentHashAlgorithm.sha256,
      value: '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
    );
    when(() => platform.hashContent(request)).thenAnswer((_) async => hash);

    expect(await sut.hashContent(request), hash);
  });
}
