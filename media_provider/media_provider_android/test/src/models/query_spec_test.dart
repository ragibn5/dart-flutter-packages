import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';

// Not const: a const set can't hold the specs, as they override `==`.
final _spec = QuerySpec(
  types: const {MediaType.photo},
  volumes: {const PrimaryVolumeSpec()},
);

void main() {
  test('toJsonShouldEncodeTypesAsWireNamesAndVolumesWithTheirType', () {
    final spec = QuerySpec(
      types: const {MediaType.photo, MediaType.video},
      volumes: {const ExternalVolumeSpec(uuid: '1A2B-3C4D')},
    );

    expect(spec.toJson(), {
      'types': ['PHOTO', 'VIDEO'],
      'volumes': [
        {'type': 'external', 'uuid': '1A2B-3C4D', 'relativePathScope': ''},
      ],
    });
  });

  test('copyWithShouldReplaceTypesIfTypesAreGiven', () {
    expect(
      _spec.copyWith(types: {MediaType.video}),
      QuerySpec(
        types: const {MediaType.video},
        volumes: {const PrimaryVolumeSpec()},
      ),
    );
  });

  test('copyWithShouldReplaceVolumesIfVolumesAreGiven', () {
    expect(
      _spec.copyWith(volumes: {const ExternalVolumeSpec(uuid: '1A2B-3C4D')}),
      QuerySpec(
        types: const {MediaType.photo},
        volumes: {const ExternalVolumeSpec(uuid: '1A2B-3C4D')},
      ),
    );
  });

  test('copyWithShouldKeepEveryFieldIfNothingIsGiven', () {
    expect(_spec.copyWith(), _spec);
  });
}
