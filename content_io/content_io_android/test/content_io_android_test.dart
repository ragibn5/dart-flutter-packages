import 'package:content_io_android/content_io_android.dart';
import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/io/sink/content_byte_sink.dart';
import 'package:content_io_android/src/io/source/content_byte_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ContentIoAndroidPlatform {}

class _MockSource extends Mock implements ContentByteSource {}

class _MockSink extends Mock implements ContentByteSink {}

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
    final session = ContentReadSession(source: _MockSource());
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
      final session = ContentReadSession(source: _MockSource());
      when(
        () => platform.openThumbnailReadSession(request),
      ).thenAnswer((_) async => session);

      expect(await sut.openThumbnailReadSession(request), same(session));
    },
  );

  test('openWriteSessionShouldReturnWhatPlatformReturnsForRequest', () async {
    const request = OpenWriteRequest(uri: 'content://media/1');
    final session = ContentWriteSession(sink: _MockSink());
    when(
      () => platform.openWriteSession(request),
    ).thenAnswer((_) async => session);

    expect(await sut.openWriteSession(request), same(session));
  });
}
