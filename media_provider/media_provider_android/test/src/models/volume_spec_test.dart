import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';

void main() {
  group('VolumeSpec', () {
    test('fromJsonShouldReturnPrimaryVolumeSpecIfTypeIsPrimary', () {
      final spec = VolumeSpec.fromJson(const {
        'type': 'primary',
        'relativePathScope': 'DCIM',
      });

      expect(spec, const PrimaryVolumeSpec(relativePathScope: 'DCIM'));
    });

    test('fromJsonShouldReturnExternalVolumeSpecIfTypeIsExternal', () {
      final spec = VolumeSpec.fromJson(const {
        'type': 'external',
        'uuid': '1A2B-3C4D',
        'relativePathScope': 'DCIM',
      });

      expect(
        spec,
        const ExternalVolumeSpec(uuid: '1A2B-3C4D', relativePathScope: 'DCIM'),
      );
    });

    test('fromJsonShouldThrowFormatExceptionIfTypeIsNotKnown', () {
      expect(
        () => VolumeSpec.fromJson(const {'type': 'cloud'}),
        throwsFormatException,
      );
    });
  });

  group('PrimaryVolumeSpec', () {
    test('relativePathScopeShouldBeEmptyIfNotGiven', () {
      expect(const PrimaryVolumeSpec().relativePathScope, isEmpty);
    });

    test('fromJsonShouldUseEmptyScopeIfRelativePathScopeIsMissing', () {
      final spec = PrimaryVolumeSpec.fromJson(const {'type': 'primary'});

      expect(spec.relativePathScope, isEmpty);
    });

    test('toJsonShouldIncludePrimaryType', () {
      const spec = PrimaryVolumeSpec(relativePathScope: 'DCIM');

      expect(spec.toJson(), {'type': 'primary', 'relativePathScope': 'DCIM'});
    });

    test('shouldNotBeEqualIfRelativePathScopesDiffer', () {
      expect(
        const PrimaryVolumeSpec(relativePathScope: 'DCIM'),
        isNot(const PrimaryVolumeSpec(relativePathScope: 'Pictures')),
      );
    });
  });

  group('ExternalVolumeSpec', () {
    test('relativePathScopeShouldBeEmptyIfNotGiven', () {
      expect(
        const ExternalVolumeSpec(uuid: '1A2B-3C4D').relativePathScope,
        isEmpty,
      );
    });

    test('fromJsonShouldUseEmptyScopeIfRelativePathScopeIsMissing', () {
      final spec = ExternalVolumeSpec.fromJson(const {'uuid': '1A2B-3C4D'});

      expect(spec.relativePathScope, isEmpty);
    });

    test('toJsonShouldIncludeExternalType', () {
      const spec = ExternalVolumeSpec(
        uuid: '1A2B-3C4D',
        relativePathScope: 'DCIM',
      );

      expect(spec.toJson(), {
        'type': 'external',
        'uuid': '1A2B-3C4D',
        'relativePathScope': 'DCIM',
      });
    });

    test('shouldNotBeEqualIfUuidsDiffer', () {
      expect(
        const ExternalVolumeSpec(uuid: '1A2B-3C4D'),
        isNot(const ExternalVolumeSpec(uuid: '5E6F-7A8B')),
      );
    });

    test('shouldNotBeEqualIfRelativePathScopesDiffer', () {
      expect(
        const ExternalVolumeSpec(uuid: '1A2B-3C4D', relativePathScope: 'DCIM'),
        isNot(
          const ExternalVolumeSpec(
            uuid: '1A2B-3C4D',
            relativePathScope: 'Pictures',
          ),
        ),
      );
    });
  });
}
