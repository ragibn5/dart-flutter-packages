import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/io/source/media_byte_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'helpers/fixtures.dart';

class _MockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements MediaProviderAndroidPlatform {}

class _MockSource extends Mock implements MediaByteSource {}

void main() {
  late MediaProviderAndroidPlatform original;
  late _MockPlatform platform;
  final sut = MediaProviderAndroid();

  setUp(() {
    original = MediaProviderAndroidPlatform.instance;
    platform = _MockPlatform();
    MediaProviderAndroidPlatform.instance = platform;
  });

  tearDown(() => MediaProviderAndroidPlatform.instance = original);

  test('getVolumesShouldReturnWhatPlatformReturns', () async {
    final volumes = <VolumeInfo>[];
    when(platform.getVolumes).thenAnswer((_) async => volumes);

    expect(await sut.getVolumes(), same(volumes));
  });

  test('getMediaShouldReturnWhatPlatformReturnsForQuery', () async {
    final query = QuerySpec(
      types: const {MediaType.photo},
      volumes: {const PrimaryVolumeSpec()},
    );
    when(() => platform.getMedia(query)).thenAnswer((_) async => [photoItem]);

    expect(await sut.getMedia(query), [photoItem]);
  });

  test('openReadSessionShouldReturnWhatPlatformReturnsForRequest', () async {
    const request = OpenMediaReadRequest(contentUri: 'content://media/1');
    final session = MediaReadSession(source: _MockSource());
    when(
      () => platform.openReadSession(request),
    ).thenAnswer((_) async => session);

    expect(await sut.openReadSession(request), same(session));
  });

  test(
    'openThumbnailReadSessionShouldReturnWhatPlatformReturnsForRequest',
    () async {
      const request = OpenThumbnailReadRequest(
        contentUri: 'content://media/1',
        size: ThumbnailSize(width: 256, height: 256),
      );
      final session = MediaReadSession(source: _MockSource());
      when(
        () => platform.openThumbnailReadSession(request),
      ).thenAnswer((_) async => session);

      expect(await sut.openThumbnailReadSession(request), same(session));
    },
  );

  test('shareMediaShouldPassRequestToPlatform', () async {
    final request = ShareMediaRequest(contentUris: const ['content://media/1']);
    when(() => platform.shareMedia(request)).thenAnswer((_) async {});

    await sut.shareMedia(request);

    verify(() => platform.shareMedia(request)).called(1);
  });

  test('openMediaWithShouldPassRequestToPlatform', () async {
    const request = OpenMediaWithRequest(contentUri: 'content://media/1');
    when(() => platform.openMediaWith(request)).thenAnswer((_) async {});

    await sut.openMediaWith(request);

    verify(() => platform.openMediaWith(request)).called(1);
  });
}
