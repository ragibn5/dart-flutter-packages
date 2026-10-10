import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/resolve_local_packages.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockReadPackageIdentity extends Mock implements ReadPackageIdentity {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockReadPackageIdentity readPackageIdentity;
  late ResolveLocalPackages sut;

  setUp(() {
    readPackageIdentity = _MockReadPackageIdentity();
    sut = ResolveLocalPackages(readPackageIdentity: readPackageIdentity);
  });

  test('should resolve each given path into a ValidLocalPackageInfo', () async {
    when(() => readPackageIdentity('/fake/repo/pkg_a')).thenAnswer(
      (_) async => const PackageIdentity(name: 'pkg_a', version: '1.0.0'),
    );
    when(() => readPackageIdentity('/fake/repo/pkg_b')).thenAnswer(
      (_) async => const PackageIdentity(name: 'pkg_b', version: '2.0.0'),
    );

    final packages = await sut(
      repoRoot: repoRoot,
      packagePaths: ['pkg_a', 'pkg_b'],
    );

    expect(packages, hasLength(2));
    expect(packages[0].repoRootRelativePath, 'pkg_a');
    expect(packages[0].packageIdentity.name, 'pkg_a');
    expect(packages[1].repoRootRelativePath, 'pkg_b');
    expect(packages[1].packageIdentity.name, 'pkg_b');
  });

  test('should preserve the given order', () async {
    when(() => readPackageIdentity(any())).thenAnswer(
      (invocation) async => PackageIdentity(
        name: (invocation.positionalArguments.first as String).split('/').last,
        version: '1.0.0',
      ),
    );

    final packages = await sut(
      repoRoot: repoRoot,
      packagePaths: ['pkg_b', 'pkg_a'],
    );

    expect(packages.map((p) => p.repoRootRelativePath), ['pkg_b', 'pkg_a']);
  });

  test('should return an empty list when given no paths', () async {
    final packages = await sut(repoRoot: repoRoot, packagePaths: const []);

    expect(packages, isEmpty);
    verifyNever(() => readPackageIdentity(any()));
  });

  test(
      'should throw PackageNotFoundException with the path and reason when '
      'a package cannot be read', () async {
    when(() => readPackageIdentity('/fake/repo/pkg_a')).thenThrow(
      const PackageIdentityException('pubspec.yaml not found.'),
    );

    await expectLater(
      sut(repoRoot: repoRoot, packagePaths: ['pkg_a']),
      throwsA(
        isA<PackageNotFoundException>().having(
          (e) => e.message,
          'message',
          'pkg_a: pubspec.yaml not found.',
        ),
      ),
    );
  });
}
