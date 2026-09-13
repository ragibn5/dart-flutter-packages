import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindPackages extends Mock implements FindPackages {}

class _MockRunPackageTestsWithCoverage extends Mock
    implements RunPackageTestsWithCoverage {}

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockFindPackages findPackages;
  late _MockRunPackageTestsWithCoverage runPackageTests;
  late _MockCalculateCoverage calculateCoverage;
  late EnforceCoverageAcrossPackages sut;

  ValidLocalPackageInfo pkg(String path, String name) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
      );

  setUp(() {
    findPackages = _MockFindPackages();
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => const <PackageInfo>[]);

    runPackageTests = _MockRunPackageTestsWithCoverage();
    when(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).thenAnswer((_) async {});

    calculateCoverage = _MockCalculateCoverage();
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 100);

    sut = EnforceCoverageAcrossPackages(
      findPackages: findPackages,
      runPackageTests: runPackageTests,
      calculateCoverage: calculateCoverage,
    );
  });

  test('should complete without checking anything when no packages are found',
      () async {
    await expectLater(sut(repoRoot: repoRoot), completes);

    verifyNever(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should run tests and check coverage for every found package', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
        (_) async => [pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);

    await sut(repoRoot: repoRoot);

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: false,
        )).called(1);
  });

  test('should skip a package under a skipped path prefix', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('app_template', 'app_template'),
        pkg('app_template/nested', 'nested'),
        pkg('pkg_a', 'pkg_a'),
      ],
    );

    await sut(repoRoot: repoRoot, skipPaths: ['app_template']);

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verifyNever(() => runPackageTests(
          packagePath: '/fake/repo/app_template',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
    verifyNever(() => runPackageTests(
          packagePath: '/fake/repo/app_template/nested',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should throw after checking every package when one fails its tests',
      () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
        (_) async => [pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);
    when(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).thenThrow(const PackageTestException('tests failed.'));

    await expectLater(
      sut(repoRoot: repoRoot),
      throwsA(isA<CoverageBatchException>()),
    );

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).called(1);
  });

  test('should throw when a package falls below the coverage threshold',
      () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 80);

    await expectLater(
      sut(repoRoot: repoRoot),
      throwsA(isA<CoverageBatchException>()),
    );
  });

  test('should not throw when every package meets the threshold', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);

    await expectLater(sut(repoRoot: repoRoot), completes);
  });
}
