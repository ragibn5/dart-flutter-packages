// ignore_for_file: lines_longer_than_80_chars

import 'package:clean_arch_linter/src/services/domain_dir_path_resolver/domain_dir_path_resolver.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late DomainDirPathResolver resolver;

  setUp(() {
    resolver = DomainDirPathResolver();
  });

  group('findDomainDirPath', () {
    test(
      'When the path contains a domain directory, returns the path up to and including it',
      () {
        const hostUnitPath =
            'lib/features/auth/domain/services/auth_service.dart';

        final result = resolver.findDomainDirPath(hostUnitPath, ['domain']);

        expect(result, 'lib/features/auth/domain/');
      },
    );

    test(
      'When the path contains a nested domain directory, returns the last occurrence',
      () {
        const hostUnitPath =
            'lib/features/domain/auth/domain/services/auth_service.dart';

        final result = resolver.findDomainDirPath(hostUnitPath, ['domain']);

        expect(result, 'lib/features/domain/auth/domain/');
      },
    );

    test(
      'When the path does not contain any domain directory, returns null',
      () {
        const hostUnitPath =
            'lib/features/auth/data/sources/local_data_source.dart';

        final result = resolver.findDomainDirPath(hostUnitPath, ['domain']);

        expect(result, isNull);
      },
    );

    test(
      'When multiple domain dir names are provided, uses the first matching one',
      () {
        const hostUnitPath =
            'lib/features/auth/domain/services/auth_service.dart';

        final result = resolver.findDomainDirPath(hostUnitPath, [
          'presentation',
          'domain',
        ]);

        expect(result, 'lib/features/auth/domain/');
      },
    );

    test('When domain dir names list is empty, returns null', () {
      const hostUnitPath =
          'lib/features/auth/domain/services/auth_service.dart';

      final result = resolver.findDomainDirPath(hostUnitPath, []);

      expect(result, isNull);
    });

    test(
      'When a custom domain dir name matches, returns the path up to it',
      () {
        const hostUnitPath =
            'lib/features/auth/core/services/auth_service.dart';

        final result = resolver.findDomainDirPath(hostUnitPath, ['core']);

        expect(result, 'lib/features/auth/core/');
      },
    );
  });
}
