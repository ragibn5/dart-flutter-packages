// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_type.dart';

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
    "volumeName": "external_primary",
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
    "volumeName": null,
    "relativePath": "DCIM/Camera/",
    "isPending": true,
    "isTrashed": false,
    "isFavorite": true
  }''';

/// The platform replies with a JSON array of media items.
const _mixedJson = '[$_photoJsonObject,$_videoJsonObject]';

const _photoItem = AndroidMediaItem(
  type: AndroidMediaType.photo,
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

const _videoItem = AndroidMediaItem(
  type: AndroidMediaType.video,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelMediaProviderAndroid.CHANNEL_NAME);
  late MethodChannelMediaProviderAndroid sut;

  /// The method calls the platform side received, in order.
  late List<MethodCall> log;

  setUp(() {
    sut = MethodChannelMediaProviderAndroid();
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

  group('getMedia', () {
    test('invokes getMedia with the requested types as wire names', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia({AndroidMediaType.photo, AndroidMediaType.video});
      await sut.getMedia({AndroidMediaType.photo});

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

      final result = await sut.getMedia({AndroidMediaType.photo, AndroidMediaType.video});

      expect(result, [_photoItem, _videoItem]);
    });

    test(
      'decodes the volume name, null or an uuid for a secondary volume',
      () async {
        const json =
            '[{"type":"photo","id":"1","uri":"content://x/1","volumeName":'
            '"external_primary"},{"type":"photo","id":"2","uri":"content://x/2",'
            '"volumeName":null}]';
        mockGetMedia(json);

        final result = await sut.getMedia({AndroidMediaType.photo});

        expect(result.map((item) => item.volumeName), [
          'external_primary',
          null,
        ]);
      },
    );

    test('returns an empty list when the library is empty', () async {
      mockGetMedia('[]');

      final result = await sut.getMedia({AndroidMediaType.photo});

      expect(result, isEmpty);
    });

    test('asserts that the requested types are not empty', () {
      mockGetMedia('[]');

      expect(() => sut.getMedia({}), throwsAssertionError);
      expect(log, isEmpty);
    });

    test(
      'propagates the code, message and details of a PlatformException',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              throw PlatformException(
                code: 'invalid_argument',
                message: "'types' must not be empty",
                details: {'argument': 'types'},
              );
            });

        await expectLater(
          sut.getMedia({AndroidMediaType.photo}),
          throwsA(
            isA<PlatformException>()
                .having((e) => e.code, 'code', 'invalid_argument')
                .having(
                  (e) => e.message,
                  'message',
                  "'types' must not be empty",
                )
                .having((e) => e.details, 'details', <String, dynamic>{
                  'argument': 'types',
                }),
          ),
        );
      },
    );
  });
}
