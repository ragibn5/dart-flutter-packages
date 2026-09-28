// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

/// JSON objects shaped exactly like `Json.encodeToString` of the Kotlin
/// `MediaItem`: every field present, nullable fields explicitly `null`.
const _photoJsonObject = '''
  {
    "type": "photo",
    "id": "1",
    "uri": "content://media/external/images/media/1",
    "name": "IMG_0001.jpg",
    "mimeType": "image/jpeg",
    "sizeInBytes": 2048,
    "dateAddedInMillis": 1700000000000,
    "dateModifiedInMillis": 1700000001000,
    "relativePath": "DCIM/Camera/",
    "isPending": false,
    "isTrashed": false,
    "isFavorite": false
  }''';

const _videoJsonObject = '''
  {
    "type": "video",
    "id": "2",
    "uri": "content://media/external/video/media/2",
    "name": "VID_0002.mp4",
    "mimeType": "video/mp4",
    "sizeInBytes": 4096,
    "dateAddedInMillis": 1700000002000,
    "dateModifiedInMillis": 1700000003000,
    "relativePath": "DCIM/Camera/",
    "isPending": true,
    "isTrashed": false,
    "isFavorite": true
  }''';

/// The platform replies with a JSON array of media items.
const _mixedJson = '[$_photoJsonObject,$_videoJsonObject]';

const _photoItem = MediaItem(
  type: MediaType.photo,
  id: '1',
  uri: 'content://media/external/images/media/1',
  name: 'IMG_0001.jpg',
  mimeType: 'image/jpeg',
  sizeInBytes: 2048,
  dateAddedInMillis: 1700000000000,
  dateModifiedInMillis: 1700000001000,
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
  relativePath: 'DCIM/Camera/',
  isPending: true,
  isTrashed: false,
  isFavorite: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('media_provider');
  late MediaProviderAndroid sut;

  /// The method calls the platform side received, in order.
  late List<MethodCall> log;

  setUp(() {
    sut = MediaProviderAndroid();
    log = <MethodCall>[];
  });

  /// Installs a platform side that answers `getMedia` with [response].
  void mockGetMedia(Object? response) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          log.add(call);
          return response;
        });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('registerWith installs itself as the platform instance', () {
    final initial = MediaProviderPlatform.instance;
    addTearDown(() => MediaProviderPlatform.instance = initial);

    MediaProviderAndroid.registerWith();

    expect(MediaProviderPlatform.instance, isA<MediaProviderAndroid>());
  });

  group('getMedia', () {
    test('invokes getMedia with the requested types as wire names', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia({MediaType.photo, MediaType.video});
      await sut.getMedia({MediaType.photo});

      expect(log, hasLength(2));
      expect(log.first.method, 'getMedia');
      expect(log.first.arguments, <String, dynamic>{
        'types': ['photo', 'video'],
      });
      expect(log.last.arguments, <String, dynamic>{
        'types': ['photo'],
      });
    });

    test('decodes the reply into media items, preserving order', () async {
      mockGetMedia(_mixedJson);

      final result = await sut.getMedia({MediaType.photo, MediaType.video});

      expect(result, [_photoItem, _videoItem]);
    });

    test('returns an empty list when the library is empty', () async {
      mockGetMedia('[]');

      final result = await sut.getMedia({MediaType.photo});

      expect(result, isEmpty);
    });

    test('asserts that the requested types are not empty', () {
      mockGetMedia('[]');

      expect(() => sut.getMedia({}), throwsAssertionError);
      expect(log, isEmpty);
    });

    test('propagates a PlatformException from the platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(
              code: 'permission_denied',
              message: 'READ_MEDIA_IMAGES permission not granted',
            );
          });

      await expectLater(
        sut.getMedia({MediaType.photo}),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'permission_denied')
              .having(
                (e) => e.message,
                'message',
                'READ_MEDIA_IMAGES permission not granted',
              ),
        ),
      );
    });
  });
}
