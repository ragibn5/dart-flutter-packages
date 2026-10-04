// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/media_codec.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

const _photoJson = <String, dynamic>{
  'type': 'photo',
  'id': '1',
  'uri': 'content://media/external/images/media/1',
  'name': 'IMG_0001.jpg',
  'mimeType': 'image/jpeg',
  'sizeInBytes': 2048,
  'dateAddedInMillis': 1700000000000,
  'dateModifiedInMillis': 1700000001000,
  'volumeName': 'external_primary',
  'relativePath': 'DCIM/Camera/',
  'isPending': false,
  'isTrashed': false,
  'isFavorite': false,
};

void main() {
  group('encodeMediaType', () {
    test('encodes to the wire names of the Kotlin MediaType enum', () {
      expect(encodeMediaType(MediaType.photo), 'photo');
      expect(encodeMediaType(MediaType.video), 'video');
    });
  });

  group('decodeMediaType', () {
    test('decodes every wire name produced by encodeMediaType', () {
      for (final type in MediaType.values) {
        expect(decodeMediaType(encodeMediaType(type)), type);
      }
    });

    test('throws a FormatException for an unknown wire name', () {
      expect(
        () => decodeMediaType('audio'),
        throwsA(
          isA<FormatException>()
              .having(
                (error) => error.message,
                'message',
                'Unknown media type',
              )
              .having((error) => error.source, 'source', 'audio'),
        ),
      );
    });
  });

  group('decodeMediaItem', () {
    test('decodes a fully populated payload', () {
      expect(
        decodeMediaItem(_photoJson),
        const MediaItem(
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
        ),
      );
    });

    test('leaves the optional fields null when the platform sends nulls', () {
      final item = decodeMediaItem(<String, dynamic>{
        'type': 'photo',
        'id': '1',
        'uri': 'content://media/external/images/media/1',
        'name': null,
        'mimeType': null,
        'sizeInBytes': null,
        'dateAddedInMillis': null,
        'dateModifiedInMillis': null,
        'volumeName': null,
        'relativePath': null,
        'isPending': null,
        'isTrashed': null,
        'isFavorite': null,
      });

      expect(
        item,
        const MediaItem(
          type: MediaType.photo,
          id: '1',
          uri: 'content://media/external/images/media/1',
          name: null,
          mimeType: null,
          sizeInBytes: null,
          dateAddedInMillis: null,
          dateModifiedInMillis: null,
          volumeName: null,
          relativePath: null,
          isPending: null,
          isTrashed: null,
          isFavorite: null,
        ),
      );
    });

    test('decodes a null uri, for platforms that have none', () {
      final item = decodeMediaItem(<String, dynamic>{
        ..._photoJson,
        'uri': null,
      });

      expect(item.uri, isNull);
    });

    test('throws a FormatException on an unknown type', () {
      expect(
        () => decodeMediaItem(<String, dynamic>{
          'type': 'audio',
          'id': '3',
          'uri': 'content://media/external/audio/media/3',
        }),
        throwsFormatException,
      );
    });
  });
}
