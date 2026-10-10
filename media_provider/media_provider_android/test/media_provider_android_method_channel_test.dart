// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
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

/// A JSON array of volumes, shaped like the Kotlin `List<VolumeInfo>`.
const _volumesJson = '''
  [
    {"isPrimary": true, "uuid": null},
    {"isPrimary": false, "uuid": "1A2B-3C4D"}
  ]''';

const _photoItem = MediaItem(
  type: MediaType.photo,
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

const _videoItem = MediaItem(
  type: MediaType.video,
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

  /// The `query` argument of [call], decoded from the JSON string it is sent as.
  Map<String, dynamic> queryOf(MethodCall call) =>
      jsonDecode((call.arguments as Map)['query'] as String)
          as Map<String, dynamic>;

  group('getMedia', () {
    test('invokes getMedia with the query as a JSON string', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia(
        QuerySpec(
          types: const {MediaType.photo, MediaType.video},
          volumes: {const VolumeSpec.primary()},
        ),
      );
      await sut.getMedia(
        QuerySpec(
          types: const {MediaType.photo},
          volumes: {const VolumeSpec.primary()},
        ),
      );

      expect(log, hasLength(2));
      expect(log.first.method, 'getMedia');
      // The whole spec crosses the channel as one JSON string, so it is
      // decoded here rather than compared as a nested map.
      expect(queryOf(log.first), <String, dynamic>{
        'types': ['PHOTO', 'VIDEO'],
        'volumes': [
          {'type': 'primary'},
        ],
      });
      expect(queryOf(log.last), <String, dynamic>{
        'types': ['PHOTO'],
        'volumes': [
          {'type': 'primary'},
        ],
      });
    });

    test('encodes each requested volume with its type discriminator', () async {
      mockGetMedia(_mixedJson);

      await sut.getMedia(
        QuerySpec(
          types: const {MediaType.photo},
          volumes: {
            const VolumeSpec.primary(),
            const VolumeSpec.external(uuid: '1A2B-3C4D'),
          },
        ),
      );

      expect(
        queryOf(log.single),
        containsPair('volumes', [
          <String, dynamic>{'type': 'primary'},
          <String, dynamic>{'type': 'external', 'uuid': '1A2B-3C4D'},
        ]),
      );
    });

    test('decodes the reply into media items, preserving order', () async {
      mockGetMedia(_mixedJson);

      final result = await sut.getMedia(
        QuerySpec(
          types: const {MediaType.photo, MediaType.video},
          volumes: {const VolumeSpec.primary()},
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
          QuerySpec(
            types: const {MediaType.photo},
            volumes: {const VolumeSpec.primary()},
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
        QuerySpec(
          types: const {MediaType.photo},
          volumes: {const VolumeSpec.primary()},
        ),
      );

      expect(result, isEmpty);
    });

    test('forwards an empty type set instead of asserting locally', () async {
      mockGetMedia('[]');

      // The emptiness rule is enforced by the platform side, which replies
      // with an 'invalid_argument' PlatformException. The Dart side must not
      // reject the query on its own.
      await sut.getMedia(
        QuerySpec(types: const {}, volumes: {const VolumeSpec.primary()}),
      );

      expect(log, hasLength(1));
      expect(queryOf(log.single), <String, dynamic>{
        'types': <String>[],
        'volumes': [
          {'type': 'primary'},
        ],
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
            QuerySpec(
              types: const {MediaType.photo},
              volumes: {const VolumeSpec.primary()},
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

  group('getVolumes', () {
    /// Installs a platform side that answers `getVolumes` with [response].
    void mockGetVolumes(Object? response) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            log.add(call);
            return response;
          });
    }

    test('invokes getVolumes without arguments', () async {
      mockGetVolumes(_volumesJson);

      await sut.getVolumes();

      expect(log, hasLength(1));
      expect(log.single.method, 'getVolumes');
      expect(log.single.arguments, isNull);
    });

    test('decodes the reply into volume infos', () async {
      mockGetVolumes(_volumesJson);

      final result = await sut.getVolumes();

      expect(result, const [
        VolumeInfo(isPrimary: true, uuid: null),
        VolumeInfo(isPrimary: false, uuid: '1A2B-3C4D'),
      ]);
    });

    test('returns an empty list when the device reports no volumes', () async {
      mockGetVolumes('[]');

      expect(await sut.getVolumes(), isEmpty);
    });

    test('propagates a PlatformException from the platform side', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'unexpected_error', message: 'boom');
          });

      await expectLater(
        sut.getVolumes(),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'unexpected_error')
              .having((e) => e.message, 'message', 'boom'),
        ),
      );
    });
  });
}
