import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindPackages extends Mock implements FindPackages {}

class _MockDetectChangesInFolder extends Mock
    implements DetectChangesInFolder {}

class _MockRunPackageTestsWithCoverage extends Mock
    implements RunPackageTestsWithCoverage {}

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

class _MockReadCoverageConfig extends Mock implements ReadCoverageConfig {}

void main() {
  const repoRoot = '/fake/repo';
  // Covers every package path used across the tests below, so each one
  // counts as touched unless a test overrides detectChangesInFolder itself.
  const defaultChangedFiles = [
    'pkg_a/lib/pkg_a.dart',
    'pkg_b/lib/pkg_b.dart',
    'app_template/lib/app_template.dart',
    'app_template/nested/lib/nested.dart',
  ];

  late _MockFindPackages findPackages;
  late _MockDetectChangesInFolder detectChangesInFolder;
  late _MockRunPackageTestsWithCoverage runPackageTests;
  late _MockCalculateCoverage calculateCoverage;
  late _MockReadCoverageConfig readCoverageConfig;
  late EnforceCoverageAcrossPackages sut;

  ValidLocalPackageInfo pkg(String path, String name) => ValidLocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
      );

  Future<void> run({
    String fromRef = 'HEAD^',
    String toRef = 'HEAD',
    double threshold = 100,
    List<String> skipPaths = const [],
    bool all = false,
  }) =>
      sut(
        repoRoot: repoRoot,
        fromRef: fromRef,
        toRef: toRef,
        globalThreshold: threshold,
        skipPaths: skipPaths,
        all: all,
      );

  setUp(() {
    findPackages = _MockFindPackages();
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => const <PackageInfo>[]);

    detectChangesInFolder = _MockDetectChangesInFolder();
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => defaultChangedFiles);

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

    sut = EnforceCoverageAcrossPackages(
      logger: _FakeLogger(),
      findPackages: findPackages,
      detectChangesInFolder: detectChangesInFolder,
      runPackageTests: runPackageTests,
      calculateCoverage: calculateCoverage,
      readCoverageConfig: readCoverageConfig,
    );
  });

  test('should complete without checking anything when no packages are found',
      () async {
    await expectLater(run(), completes);

    verifyNever(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should diff with fromRef as the base and toRef as the compare ref',
      () async {
    await run(fromRef: 'main~1', toRef: 'main');

    verify(() => detectChangesInFolder(
          baseRef: 'main~1',
          compareRef: 'main',
        )).called(1);
  });

  test('should run tests and check coverage for every touched package',
      () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
        (_) async => [pkg('pkg_a', 'pkg_a'), pkg('pkg_b', 'pkg_b')]);

    await run();

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_b',
          isFlutterPackage: false,
        )).called(1);
  });

  test('should not check a package that was not touched by the diff', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => ['docs/readme.md']);

    await expectLater(run(), completes);

    verifyNever(() => runPackageTests(
          packagePath: any(named: 'packagePath'),
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should check every package when all is true, ignoring what changed',
      () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => <String>[]);

    await run(all: true);

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verifyNever(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        ));
  });

  test('should still respect skipPaths when all is true', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('app_template', 'app_template'),
        pkg('pkg_a', 'pkg_a'),
      ],
    );

    await run(all: true, skipPaths: ['app_template']);

    verify(() => runPackageTests(
          packagePath: '/fake/repo/pkg_a',
          isFlutterPackage: false,
        )).called(1);
    verifyNever(() => runPackageTests(
          packagePath: '/fake/repo/app_template',
          isFlutterPackage: any(named: 'isFlutterPackage'),
        ));
  });

  test('should skip a package under a skipped path prefix', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot'))).thenAnswer(
      (_) async => [
        pkg('app_template', 'app_template'),
        pkg('app_template/nested', 'nested'),
        pkg('pkg_a', 'pkg_a'),
      ],
    );

    await run(skipPaths: ['app_template']);

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

    await expectLater(run(), throwsA(isA<CoverageBatchException>()));

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

    await expectLater(run(), throwsA(isA<CoverageBatchException>()));
  });

  test('should not throw when every package meets the threshold', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);

    await expectLater(run(), completes);
  });

  test(
      "should use a package's own dev_tools_coverage_config.yaml "
      'threshold instead of the batch default', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
    when(() => readCoverageConfig(any()))
        .thenAnswer((_) async => (exclude: const <String>[], threshold: 80.0));
    when(() => calculateCoverage(any(), any())).thenAnswer((_) async => 85);

    await expectLater(run(), completes);
  });

  test('should still fail below an overridden (lower) threshold', () async {
    when(() => findPackages(repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async => [pkg('pkg_a', 'pkg_a')]);
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
