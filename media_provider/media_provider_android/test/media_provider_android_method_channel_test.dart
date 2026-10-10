// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/src/models/android_media_item.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/android_media_type.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';

/// JSON objects shaped exactly like `Json.encodeToString` of the Kotlin
/// `MediaItem`: every field present, nullable fields explicitly `null`.
const _photoJsonObject = '''
  {
    "type": "PHOTO",
    "id": "1",
    "uri": "content://media/external/images/media/1",
    "name": "IMG_0001.jpg",
    "mimeType": "image/jpeg",
    "sizeInBytes": 2048,
    "dateAddedInMillis": 1700000000000,
    "dateModifiedInMillis": 1700000001000,
    "dateTakenInMillis": 1700000002000,
    "volumeInfo": {"isPrimary": true, "uuid": null},
    "relativePath": "DCIM/Camera/",
    "ownerPackageName": "com.android.camera3",
    "isPending": false,
    "isTrashed": false,
    "isFavorite": false,
    "isDownloaded": false
  }''';

const _videoJsonObject = '''
  {
    "type": "VIDEO",
    "id": "2",
    "uri": "content://media/external/video/media/2",
    "name": "VID_0002.mp4",
    "mimeType": "video/mp4",
    "sizeInBytes": 4096,
    "dateAddedInMillis": 1700000002000,
    "dateModifiedInMillis": 1700000003000,
    "dateTakenInMillis": null,
    "volumeInfo": null,
    "relativePath": "DCIM/Camera/",
    "ownerPackageName": null,
    "isPending": true,
    "isTrashed": false,
    "isFavorite": true,
    "isDownloaded": null
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
  dateTakenInMillis: 1700000002000,
  volumeInfo: VolumeInfo(isPrimary: true, uuid: null),
  relativePath: 'DCIM/Camera/',
  ownerPackageName: 'com.android.camera3',
  isPending: false,
  isTrashed: false,
  isFavorite: false,
  isDownloaded: false,
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
  dateTakenInMillis: null,
  volumeInfo: null,
  relativePath: 'DCIM/Camera/',
  ownerPackageName: null,
  isPending: true,
  isTrashed: false,
  isFavorite: true,
  isDownloaded: null,
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
    test('invokes getMedia with the query as a nested argument', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia(
        const QuerySpec(
          types: {AndroidMediaType.photo, AndroidMediaType.video},
          volumes: null,
        ),
      );
      await sut.getMedia(
        const QuerySpec(types: {AndroidMediaType.photo}, volumes: null),
      );

      expect(log, hasLength(2));
      expect(log.first.method, 'getMedia');
      expect(log.first.arguments, <String, dynamic>{
        'query': <String, dynamic>{
          'types': ['PHOTO', 'VIDEO'],
          'volumes': null,
        },
      });
      expect(log.last.arguments, <String, dynamic>{
        'query': <String, dynamic>{
          'types': ['PHOTO'],
          'volumes': null,
        },
      });
    });

    test('encodes each requested volume as its own object', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia(
        QuerySpec(
          types: const {AndroidMediaType.photo},
          volumes: {
            VolumeSpec.primary(),
            VolumeSpec.external(uuid: '1A2B-3C4D'),
          },
        ),
      );

      expect(
        (log.single.arguments as Map)['query'],
        containsPair('volumes', [
          <String, dynamic>{'isPrimary': true, 'uuid': null},
          <String, dynamic>{'isPrimary': false, 'uuid': '1A2B-3C4D'},
        ]),
      );
    });

    test('decodes the reply into media items, preserving order', () async {
      mockGetMedia(_mixedJson);

      final result = await sut.getMedia(
        const QuerySpec(
          types: {AndroidMediaType.photo, AndroidMediaType.video},
          volumes: null,
        ),
      );

      expect(result, [_photoItem, _videoItem]);
    });

    test(
      'decodes the volume info, null or an uuid for a secondary volume',
      () async {
        const json =
            '[{"type":"PHOTO","id":"1","uri":"content://x/1","volumeInfo":'
            '{"isPrimary":true,"uuid":null}},{"type":"PHOTO","id":"2",'
            '"uri":"content://x/2","volumeInfo":{"isPrimary":false,'
            '"uuid":"1A2B-3C4D"}},{"type":"PHOTO","id":"3",'
            '"uri":"content://x/3","volumeInfo":null}]';
        mockGetMedia(json);

        final result = await sut.getMedia(
          const QuerySpec(
            types: {AndroidMediaType.photo},
            volumes: null,
          ),
        );

        expect(result.map((item) => item.volumeInfo), [
          const VolumeInfo(isPrimary: true, uuid: null),
          const VolumeInfo(isPrimary: false, uuid: '1A2B-3C4D'),
          null,
        ]);
      },
    );

    test('returns an empty list when the library is empty', () async {
      mockGetMedia('[]');

      final result = await sut.getMedia(
        const QuerySpec(types: {AndroidMediaType.photo}, volumes: null),
      );

      expect(result, isEmpty);
    });

    test('forwards an empty type set instead of asserting locally', () async {
      mockGetMedia('[]');

      // The emptiness rule is enforced by the platform side, which replies
      // with an 'invalid_argument' PlatformException. The Dart side must not
      // reject the query on its own.
      await sut.getMedia(const QuerySpec(types: {}, volumes: null));

      expect(log, hasLength(1));
      expect(log.single.arguments, <String, dynamic>{
        'query': <String, dynamic>{'types': <String>[], 'volumes': null},
      });
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
          sut.getMedia(
            const QuerySpec(
              types: {AndroidMediaType.photo},
              volumes: null,
            ),
          ),
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
