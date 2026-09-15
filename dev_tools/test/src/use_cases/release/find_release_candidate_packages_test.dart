import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockPackageRegistryClient extends Mock
    implements PackageRegistryClient {}

void main() {
  late _MockPackageRegistryClient packageRegistryClient;
  late FindReleaseCandidatePackages sut;

  ValidLocalPackageInfo localPackage(
    String path,
    String name,
    String? version, {
    bool isPublishable = true,
  }) =>
      ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(
          name: name,
          version: version,
          // Mirrors ParsePubspecContent's actual invariant: publishable
          // requires both no `publish_to: none` AND a version.
          isPublishable: isPublishable && version != null,
        ),
      );

  setUp(() {
    packageRegistryClient = _MockPackageRegistryClient();

    when(() => packageRegistryClient(any()))
        .thenAnswer((_) async => const PublishedPackageInfo());

    sut = FindReleaseCandidatePackages(
      packageRegistryClient: packageRegistryClient,
    );
  });

  test('should return a brand-new package as a candidate', () async {
    final result = await sut(
      localPackages: [localPackage('pkg_a', 'pkg_a', '1.0.0')],
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
    expect(result.single.repoRootRelativePath, 'pkg_a');
    expect(result.single.packageIdentity.name, 'pkg_a');
  });

  test('should return a package with a version bump as a candidate', () async {
    when(() => packageRegistryClient('pkg_a')).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    final result = await sut(
      localPackages: [localPackage('pkg_a', 'pkg_a', '1.1.0')],
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
    expect(result.single.packageIdentity.version, '1.1.0');
  });

  test(
      'should not return a package whose current version is already '
      'published', () async {
    when(() => packageRegistryClient('pkg_a')).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    final result = await sut(
      localPackages: [localPackage('pkg_a', 'pkg_a', '1.0.0')],
      changedFiles: ['pkg_a/README.md'],
    );

    expect(result, isEmpty);
  });

  test('should ignore a package with publish_to: none', () async {
    final result = await sut(
      localPackages: [
        localPackage('my_app', 'my_app', '1.0.0', isPublishable: false),
      ],
      changedFiles: ['my_app/lib/main.dart'],
    );

    expect(result, isEmpty);
    verifyNever(() => packageRegistryClient(any()));
  });

  test('should ignore a package with no version', () async {
    final result = await sut(
      localPackages: [localPackage('pkg_a', 'pkg_a', null)],
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, isEmpty);
    verifyNever(() => packageRegistryClient(any()));
  });

  test('should ignore a package with no changed files', () async {
    final result = await sut(
      localPackages: [localPackage('pkg_a', 'pkg_a', '1.0.0')],
      changedFiles: ['docs/readme.md'],
    );

    expect(result, isEmpty);
    verifyNever(() => packageRegistryClient(any()));
  });

  test('should treat a change inside a nested package directory as touched',
      () async {
    final result = await sut(
      localPackages: [localPackage('packages/pkg_a', 'pkg_a', '1.0.0')],
      changedFiles: ['packages/pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
  });

  test('should return multiple candidates when several packages are touched',
      () async {
    final result = await sut(
      localPackages: [
        localPackage('pkg_a', 'pkg_a', '1.0.0'),
        localPackage('pkg_b', 'pkg_b', '2.0.0'),
      ],
      changedFiles: ['pkg_a/lib/pkg_a.dart', 'pkg_b/lib/pkg_b.dart'],
    );

    expect(
      result.map((c) => c.packageIdentity.name).toList()..sort(),
      ['pkg_a', 'pkg_b'],
    );
  });

  test('should propagate PackageRegistryLookupException', () async {
    when(() => packageRegistryClient('pkg_a')).thenThrow(
      const PackageRegistryLookupException('connection timeout'),
    );

    await expectLater(
      sut(
        localPackages: [localPackage('pkg_a', 'pkg_a', '1.0.0')],
        changedFiles: ['pkg_a/lib/pkg_a.dart'],
      ),
      throwsA(isA<PackageRegistryLookupException>()),
    );
  });
}
