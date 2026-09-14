import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/verify_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/resolve_local_packages.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockResolveLocalPackages extends Mock implements ResolveLocalPackages {}

class _MockRunPackageTestsWithCoverage extends Mock
    implements RunPackageTestsWithCoverage {}

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

class _MockReadCoverageConfig extends Mock implements ReadCoverageConfig {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockResolveLocalPackages resolveLocalPackages;
  late _MockRunPackageTestsWithCoverage runPackageTests;
  late _MockCalculateCoverage calculateCoverage;
  late _MockReadCoverageConfig readCoverageConfig;
  late VerifyCoverageAcrossPackages sut;

  ValidLocalPackageInfo pkg(String path, String name) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
      );

  Future<void> run({
    List<String> packagePaths = const ['pkg_a'],
    double threshold = 100,
  }) =>
      sut(
        repoRoot: repoRoot,
        packagePaths: packagePaths,
        globalThreshold: threshold,
      );

  void resolvesTo(List<ValidLocalPackageInfo> packages) {
    when(() => resolveLocalPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
        )).thenAnswer((_) async => packages);
  }

  setUp(() {
    resolveLocalPackages = _MockResolveLocalPackages();
    resolvesTo([pkg('pkg_a', 'pkg_a')]);

    runPackageTests = _MockRunPackageTestsWithCoverage();
    when(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).thenAnswer((_) async {});

    calculateCoverage = _MockCalculateCoverage();
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 100);

    readCoverageConfig = _MockReadCoverageConfig();
    when(() => readCoverageConfig(any()))
        .thenAnswer((_) async => (exclude: const <String>[], threshold: null));

    sut = VerifyCoverageAcrossPackages(
      logger: _FakeLogger(),
      resolveLocalPackages: resolveLocalPackages,
      runPackageTests: runPackageTests,
      calculateCoverage: calculateCoverage,
      readCoverageConfig: readCoverageConfig,
    );
  });

  test('should resolve the given package paths under the repo root', () async {
    await run(packagePaths: ['pkg_a', 'pkg_b']);

    verify(() => resolveLocalPackages(
          repoRoot: repoRoot,
          packagePaths: ['pkg_a', 'pkg_b'],
        )).called(1);
  });

  test('should complete without checking anything when given no packages',
      () async {
    resolvesTo(const []);

    await expectLater(run(packagePaths: const []), completes);

    verifyNever(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should run tests and check coverage for every given package', () async {
    resolvesTo([pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);

    await run(packagePaths: ['pkg_a', 'pkg_b']);

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: false,
        )).called(1);
  });

  test('should propagate PackageNotFoundException from resolution', () async {
    when(() => resolveLocalPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
        )).thenThrow(const PackageNotFoundException('nope: not found.'));

    await expectLater(run(), throwsA(isA<PackageNotFoundException>()));
  });

  test('should throw after checking every package when one fails its tests',
      () async {
    resolvesTo([pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);
    when(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).thenThrow(const PackageTestException('tests failed.'));

    await expectLater(
      run(packagePaths: ['pkg_a', 'pkg_b']),
      throwsA(isA<CoverageBatchException>()),
    );

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).called(1);
  });

  test('should stop checking remaining packages when failFast is true',
      () async {
    resolvesTo([pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);
    when(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        )).thenThrow(const PackageTestException('tests failed.'));

    await expectLater(
      sut(
        repoRoot: repoRoot,
        packagePaths: ['pkg_a', 'pkg_b'],
        failFast: true,
      ),
      throwsA(isA<CoverageBatchException>()),
    );

    verifyNever(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should throw when a package falls below the coverage threshold',
      () async {
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 80);

    await expectLater(run(), throwsA(isA<CoverageBatchException>()));
  });

  test('should not throw when every package meets the threshold', () async {
    await expectLater(run(), completes);
  });

  test(
      "should use a package's own dev_tools_coverage_config.yaml "
      'threshold instead of the batch default', () async {
    when(() => readCoverageConfig(any()))
        .thenAnswer((_) async => (exclude: const <String>[], threshold: 80.0));
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 85);

    await expectLater(run(), completes);
  });

  test('should still fail below an overridden (lower) threshold', () async {
    when(() => readCoverageConfig(any()))
        .thenAnswer((_) async => (exclude: const <String>[], threshold: 80.0));
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 75);

    await expectLater(run(), throwsA(isA<CoverageBatchException>()));
  });
}

class _FakeLogger extends Logger {
  @override
  void log(LogLevel level, String message, {StackTrace? stackTrace}) {}
}
