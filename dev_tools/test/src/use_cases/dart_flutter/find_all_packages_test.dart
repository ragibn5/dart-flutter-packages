import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_all_packages.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindPackages extends Mock implements FindPackages {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockFindPackages findPackages;
  late FindAllPackages sut;

  ValidLocalPackageInfo pkg(String path, String name) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
      );

  setUp(() {
    findPackages = _MockFindPackages();
    sut = FindAllPackages(findPackages: findPackages);
  });

  test('should return every valid package found, ignoring malformed ones',
      () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('pkg_a', 'pkg_a'),
        pkg('pkg_b', 'pkg_b'),
        const MalformedLocalPackageInfo(
          repoRootRelativePath: 'broken',
          reason: 'pubspec.yaml not found.',
        ),
      ],
    );

    final result = await sut(repoRoot: repoRoot);

    expect(result.map((p) => p.repoRootRelativePath), ['pkg_a', 'pkg_b']);
  });

  test('should return an empty list when no packages are found', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => const <PackageInfo>[]);

    final result = await sut(repoRoot: repoRoot);

    expect(result, isEmpty);
  });

  test('should skip a package under a skipped path prefix', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('app_template', 'app_template'),
        pkg('app_template/nested', 'nested'),
        pkg('pkg_a', 'pkg_a'),
      ],
    );

    final result = await sut(repoRoot: repoRoot, skipPaths: ['app_template']);

    expect(result.map((p) => p.repoRootRelativePath), ['pkg_a']);
  });
}
