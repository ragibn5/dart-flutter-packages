import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';
import 'package:media_provider_android/src/models/volume_type.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromJsonShouldDecodeEveryFieldIfJsonIsComplete', () {
    expect(
      VolumeIdentity.fromJson(primaryVolumeIdentityJson),
      primaryVolumeIdentity,
    );
  });

  test('fromJsonShouldDecodeUnknownTypeIfTypeIsNotKnown', () {
    final identity = VolumeIdentity.fromJson(
      Map.of(primaryVolumeIdentityJson)..['type'] = 'NETWORK',
    );

    expect(identity.type, VolumeType.unknown);
  });

  test('toJsonShouldEncodeTypeAsItsWireName', () {
    expect(primaryVolumeIdentity.toJson(), primaryVolumeIdentityJson);
  });
}
