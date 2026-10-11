// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';
import 'package:media_provider_android/src/models/volume_state.dart';
import 'package:media_provider_android/src/models/volume_type.dart';

/// Serialization of the models that carry a nested model.
///
/// A nested model that a parent's `toJson` emits as the object rather than as
/// the map `toJson` returns survives only because `jsonEncode` recurses into
/// it. Calling `toJson` directly, which is what any caller storing the result
/// elsewhere does, then hands back something that cannot be encoded. Every model
/// with a nested one is pinned here so that cannot come back unnoticed.
void main() {
  const identity = VolumeIdentity(
    isPrimary: true,
    isRemovable: false,
    isEmulated: true,
    type: VolumeType.primary,
    capacityInBytes: 128000000000,
    uuid: null,
  );

  const volume = VolumeInfo(
    identity: identity,
    state: VolumeState.mounted,
    availableSpaceInBytes: 64000000000,
  );

  group('VolumeInfo', () {
    test('encodes on its own, without jsonEncode to recurse for it', () {
      final json = volume.toJson();

      expect(json['identity'], isA<Map<String, dynamic>>());
      expect(jsonEncode(json), isA<String>());
    });

    test('survives a round trip through JSON', () {
      expect(VolumeInfo.fromJson(jsonDecode(jsonEncode(volume)) as Map<String, dynamic>), volume);
    });

    test('carries the sizes through the round trip', () {
      final decoded = VolumeInfo.fromJson(jsonDecode(jsonEncode(volume)) as Map<String, dynamic>);

      expect(decoded.identity.capacityInBytes, 128000000000);
      expect(decoded.availableSpaceInBytes, 64000000000);
    });
  });

  group('MediaItem', () {
    const item = MediaItem(
      type: MediaType.photo,
      id: '1',
      uri: 'content://media/external/images/media/1',
      name: 'IMG_0001.jpg',
      mimeType: 'image/jpeg',
      sizeInBytes: 2048,
      dateAddedInMillis: 1700000000000,
      dateModifiedInMillis: 1700000001000,
      dateTakenInMillis: 1700000002000,
      volumeIdentity: identity,
      relativePath: 'DCIM/Camera/',
      ownerPackageName: null,
      isPending: null,
      isTrashed: null,
      isFavorite: null,
      isDownloaded: null,
    );

    test('encodes its volume on its own, without jsonEncode to recurse', () {
      final json = item.toJson();

      expect(json['volumeIdentity'], isA<Map<String, dynamic>>());
      expect(jsonEncode(json), isA<String>());
    });

    test('encodes an absent volume as null', () {
      expect(item.copyWithVolume(null).toJson()['volumeIdentity'], isNull);
    });

    test('carries the volume size through the round trip', () {
      final decoded = MediaItem.fromJson(jsonDecode(jsonEncode(item)) as Map<String, dynamic>);

      expect(decoded.volumeIdentity?.capacityInBytes, 128000000000);
    });

    test('survives a round trip through JSON', () {
      expect(MediaItem.fromJson(jsonDecode(jsonEncode(item)) as Map<String, dynamic>), item);
    });
  });

  group('QuerySpec', () {
    final spec = QuerySpec(
      types: const {MediaType.photo},
      volumes: {
        const PrimaryVolumeSpec(),
        const ExternalVolumeSpec(uuid: '1A2B-3C4D'),
      },
    );

    test('encodes its volumes on their own, without jsonEncode to recurse', () {
      final json = spec.toJson();

      expect(json['volumes'], everyElement(isA<Map<String, dynamic>>()));
      expect(jsonEncode(json), isA<String>());
    });

    test('survives a round trip through JSON', () {
      expect(QuerySpec.fromJson(jsonDecode(jsonEncode(spec)) as Map<String, dynamic>), spec);
    });
  });
}

/// A [MediaItem] carrying the given volume, so the tests above can ask for one
/// with and one without.
extension on MediaItem {
  MediaItem copyWithVolume(VolumeIdentity? volume) => MediaItem(
    type: type,
    id: id,
    uri: uri,
    name: name,
    mimeType: mimeType,
    sizeInBytes: sizeInBytes,
    dateAddedInMillis: dateAddedInMillis,
    dateModifiedInMillis: dateModifiedInMillis,
    dateTakenInMillis: dateTakenInMillis,
    volumeIdentity: volume,
    relativePath: relativePath,
    ownerPackageName: ownerPackageName,
    isPending: isPending,
    isTrashed: isTrashed,
    isFavorite: isFavorite,
    isDownloaded: isDownloaded,
  );
}
