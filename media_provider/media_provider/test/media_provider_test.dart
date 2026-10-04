// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider/media_provider.dart' as barrel;
import 'package:media_provider/media_provider.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class _MockMediaProviderPlatform extends Mock
    implements MediaProviderPlatform {}

const _photoItem = MediaItem(
  type: MediaType.photo,
  id: '1',
  uri: 'content://media/external/images/media/1',
  name: 'IMG_0001.jpg',
  mimeType: 'image/jpeg',
  sizeInBytes: 2048,
  dateAddedInMillis: 1700000000000,
  dateModifiedInMillis: 1700000001000,
  volumeName: 'external_primary',
  relativePath: 'DCIM/Camera/',
  isPending: false,
  isTrashed: false,
  isFavorite: false,
);

const _videoItem = MediaItem(
  type: MediaType.video,
  id: '2',
  uri: 'content://media/external/video/media/2',
  name: 'VID_0002.mp4',
  mimeType: 'video/mp4',
  sizeInBytes: 4096,
  dateAddedInMillis: 1700000002000,
  dateModifiedInMillis: 1700000003000,
  volumeName: null,
  relativePath: 'DCIM/Camera/',
  isPending: true,
  isTrashed: false,
  isFavorite: true,
);

void main() {
  late _MockMediaProviderPlatform mockPlatform;

  late MediaProviderPlatform initialPlatform;

  late MediaProvider sut;

  setUpAll(() {
    registerFallbackValue(<MediaType>{});
  });

  setUp(() {
    initialPlatform = MediaProviderPlatform.instance;
    mockPlatform = _MockMediaProviderPlatform();
    when(() => mockPlatform.getMedia(any())).thenAnswer((_) async => []);
    MediaProviderPlatform.instance = mockPlatform;

    sut = MediaProvider.instance;
  });

  tearDown(() {
    MediaProviderPlatform.instance = initialPlatform;
  });

  group('instance', () {
    test('is a singleton', () {
      expect(sut, same(MediaProvider.instance));
    });
  });

  group('getMedia', () {
    test('forwards the given types to the platform, only once', () async {
      final types = <MediaType>{MediaType.photo, MediaType.video};

      await sut.getMedia(types);

      final captured = verify(
        () => mockPlatform.getMedia(captureAny()),
      ).captured;

      expect(captured.single, same(types));
    });

    test('queries the platform instance set at call time', () async {
      final otherMock = _MockMediaProviderPlatform();
      when(() => otherMock.getMedia(any())).thenAnswer((_) async => []);
      MediaProviderPlatform.instance = otherMock;

      await sut.getMedia({MediaType.video});

      verify(() => otherMock.getMedia({MediaType.video})).called(1);
      verifyNever(() => mockPlatform.getMedia(any()));
    });

    test('returns the media items provided by the platform', () async {
      when(
        () => mockPlatform.getMedia(any()),
      ).thenAnswer((_) async => [_photoItem, _videoItem]);

      final result = await sut.getMedia({MediaType.photo, MediaType.video});

      expect(result, [_photoItem, _videoItem]);
    });

    test('returns an empty list when the platform has no media', () async {
      when(() => mockPlatform.getMedia(any())).thenAnswer((_) async => []);

      final result = await sut.getMedia({MediaType.photo});

      expect(result, isEmpty);
    });

    test('propagates a future failed by the platform', () async {
      when(
        () => mockPlatform.getMedia(any()),
      ).thenAnswer((_) => Future.error(Exception('boom')));

      await expectLater(
        sut.getMedia({MediaType.photo}),
        throwsA(isA<Exception>()),
      );
    });

    test('does not swallow a synchronous throw of the platform', () {
      MediaProviderPlatform.instance = initialPlatform;

      expect(
        () => sut.getMedia({MediaType.photo}),
        throwsA(
          isA<UnimplementedError>().having(
            (error) => error.message,
            'message',
            'getMedia() has not been implemented.',
          ),
        ),
      );
    });
  });

  group('exports', () {
    test('re-exports MediaItem and MediaType', () {
      expect(barrel.MediaItem, MediaItem);
      expect(barrel.MediaType, MediaType);
    });
  });
}
