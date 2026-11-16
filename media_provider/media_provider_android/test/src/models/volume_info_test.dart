import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/models/volume_state.dart';

import '../../helpers/fixtures.dart';

const _volumeInfoJson = <String, dynamic>{
  'identity': primaryVolumeIdentityJson,
  'state': 'MOUNTED',
  'availableSpaceInBytes': 64000000000,
  'documentsRootUri': primaryRootUri,
};

void main() {
  test('fromJsonShouldDecodeEveryFieldIfJsonIsComplete', () {
    expect(
      VolumeInfo.fromJson(_volumeInfoJson),
      const VolumeInfo(
        identity: primaryVolumeIdentity,
        state: VolumeState.mounted,
        availableSpaceInBytes: 64000000000,
        documentsRootUri: primaryRootUri,
      ),
    );
  });

  test('fromJsonShouldDecodeUnknownStateIfStateIsNotKnown', () {
    final info = VolumeInfo.fromJson(
      Map.of(_volumeInfoJson)..['state'] = 'FROZEN',
    );

    expect(info.state, VolumeState.unknown);
  });

  test('fromJsonShouldDecodeNullSpaceIfAvailableSpaceIsNull', () {
    final info = VolumeInfo.fromJson(
      Map.of(_volumeInfoJson)..['availableSpaceInBytes'] = null,
    );

    expect(info.availableSpaceInBytes, isNull);
  });

  test('toJsonShouldEncodeIdentityAsMap', () {
    const info = VolumeInfo(
      identity: primaryVolumeIdentity,
      state: VolumeState.mounted,
      availableSpaceInBytes: 64000000000,
      documentsRootUri: primaryRootUri,
    );

    expect(info.toJson(), _volumeInfoJson);
  });
}
