import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/exceptions/coverage_threshold_exception.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/filter_touched_packages.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

/// Orchestrates running every package's tests with coverage and enforcing a
/// minimum line-coverage threshold on each.
///
/// Runs independently per package — one failing doesn't stop the rest —
/// then reports a per-package summary and fails the batch (via
/// [CoverageBatchException]) if any package failed.
class VerifyCoverageAcrossPackages {
  final Logger _logger;
  final FindPackages _findPackages;
  final DetectChangesInFolder _detectChangesInFolder;
  final FilterTouchedPackages _filterTouchedPackages;
  final CalculateCoverage _calculateCoverage;
  final RunPackageTestsWithCoverage _runPackageTests;
  final ReadCoverageConfig _readCoverageConfig;

  const VerifyCoverageAcrossPackages({
    Logger logger = const ConsoleLogger(),
    FindPackages findPackages = const FindPackages(),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FilterTouchedPackages filterTouchedPackages = const FilterTouchedPackages(),
    CalculateCoverage calculateCoverage = const CalculateCoverage(),
    RunPackageTestsWithCoverage runPackageTests =
        const RunPackageTestsWithCoverage(),
    ReadCoverageConfig readCoverageConfig = const ReadCoverageConfig(),
  })  : _logger = logger,
        _findPackages = findPackages,
        _detectChangesInFolder = detectChangesInFolder,
        _filterTouchedPackages = filterTouchedPackages,
        _calculateCoverage = calculateCoverage,
        _runPackageTests = runPackageTests,
        _readCoverageConfig = readCoverageConfig;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root to scan.
  /// - `fromRef`: the ref to diff from, i.e. the branch's state before this
  ///   change (e.g. the PR's base commit). Unused when [all] is true.
  /// - `toRef`: the ref to diff against, i.e. the branch's state after this
  ///   change (e.g. `HEAD`). Unused when [all] is true.
  /// - `threshold`: required coverage percentage (default 100) — a
  ///   package's own `dev_tools_coverage_config.yaml` may override this
  ///   for itself.
  /// - `skipPaths`: repo-root-relative path prefixes of whole packages to
  ///   skip entirely (e.g. `app_template`, which has its own dedicated CI
  ///   coverage flow) — not to be confused with a package's own
  ///   `dev_tools_coverage_config.yaml`, which filters files (and/or
  ///   overrides the threshold) within one package's coverage rather than
  ///   skipping the package altogether.
  /// - `all`: when true, check every found package regardless of what
  ///   changed between [fromRef] and [toRef] — no diffing happens at all.
  ///
  /// Returns: nothing (void) when every checked package meets its
  /// (possibly overridden) threshold.
  ///
  /// Throws:
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  /// - [GitDiffingException] when `git diff` fails (only when `!all`).
  /// - [CoverageBatchException] listing every package that failed its tests
  ///   or fell below [globalThreshold] (or package specific override), once
  ///   every package has been checked.
  Future<void> call({
    required String repoRoot,
    required String fromRef,
    required String toRef,
    double globalThreshold = 100,
    List<String> skipPaths = const [],
    bool all = false,
  }) async {
    final packages = await _logger.withGroupedLog(
      'Scanning for packages...',
      (logger) => _extractPackages(repoRoot, skipPaths, logger),
    );
    final packagesToCheck = all
        ? packages
        : await _logger.withGroupedLog(
            'Filtering touched packages...',
            (logger) =>
                _extractTouchedPackages(fromRef, toRef, packages, logger),
          );

    final results = await _checkPackages(
      repoRoot,
      globalThreshold,
      packagesToCheck,
    );
    _logger.info(
      'Coverage report for ${packagesToCheck.length} package(s):\n'
      '${_buildSummary(packagesToCheck, results)}',
    );

    if (results.issueMap.isNotEmpty) {
      throw CoverageBatchException(
        '${results.issueMap.length} package(s) failed coverage enforcement.',
      );
    }
  }

  Future<List<ValidLocalPackageInfo>> _extractPackages(
    String repoRoot,
    List<String> skipPaths,
    Logger logger,
  ) async {
    final foundPackages = await _findPackages(repoRoot: repoRoot);
    final validPackages = foundPackages
        .whereType<ValidLocalPackageInfo>()
        .where((pkg) => !_isSkipped(pkg.repoRootRelativePath, skipPaths))
        .toList();
    final malformedPackages =
        foundPackages.whereType<MalformedLocalPackageInfo>().toList();

    logger
      ..info('Found ${foundPackages.length} package(s)')
      ..info('  Valid: ${validPackages.length}')
      ..info('  Malformed: ${malformedPackages.length}')
      ..info(
        malformedPackages
            .map((e) => '  - ${e.repoRootRelativePath}: ${e.reason}')
            .join('\n')
            .trim(),
      );

    return validPackages;
  }

  Future<List<ValidLocalPackageInfo>> _extractTouchedPackages(
    String fromRef,
    String toRef,
    List<ValidLocalPackageInfo> packages,
    Logger logger,
  ) async {
    final changedFiles = await _detectChangesInFolder(
      baseRef: fromRef,
      compareRef: toRef,
    );
    final touched = _filterTouchedPackages(
      localPackages: packages,
      changedFiles: changedFiles,
    );

    if (touched.isEmpty) {
      logger.info('No packages touched; nothing to check.');
    } else {
      logger
          .info('${touched.length} of ${packages.length} package(s) touched.');
    }

    return touched;
  }

  bool _isSkipped(String repoRootRelativePath, List<String> skipPaths) =>
      skipPaths.any(
        (prefix) =>
            repoRootRelativePath == prefix ||
            repoRootRelativePath.startsWith('$prefix/'),
      );

  Future<_CheckResult> _checkPackages(
    String repoRoot,
    double globalThreshold,
    List<ValidLocalPackageInfo> packages,
  ) async {
    final issueMap = <String, String>{};
    final effectiveThresholds = <String, double>{};
    for (var i = 0; i < packages.length; ++i) {
      final package = packages[i];
      final name = package.packageIdentity.name;
      final packagePath = p.join(repoRoot, package.repoRootRelativePath);

      // Read upfront (can't fail) so every checked package's threshold is
      // known regardless of whether its check below passes or throws.
      final config = await _readCoverageConfig(packagePath);
      effectiveThresholds[name] = config.threshold ?? globalThreshold;

      await _logger.withGroupedLog(
        '[${i + 1}/${packages.length}] Checking $name ...',
        (logger) async {
          try {
            await _checkPackage(
              package,
              packagePath,
              effectiveThresholds[name]!,
            );
          } catch (e) {
            issueMap[name] = e.toString();
          }
        },
      );
    }
    return (issueMap: issueMap, effectiveThresholds: effectiveThresholds);
  }

  /// Throws [CoverageThresholdException] when [package]'s coverage
  /// falls below [threshold].
  Future<void> _checkPackage(
    ValidLocalPackageInfo package,
    String packagePath,
    double threshold,
  ) async {
    await _runPackageTests(
      packagePath: packagePath,
      isFlutterPackage: package.packageIdentity.isFlutterPackage,
    );
    final pct = await _calculateCoverage('coverage/lcov.info', packagePath);
    if (pct < threshold) {
      throw CoverageThresholdException(
        'Coverage $pct% is below required $threshold%.',
      );
    }
  }

  String _buildSummary(
    List<ValidLocalPackageInfo> packages,
    _CheckResult results,
  ) {
    const tick = '✅';
    const cross = '❌';
    return [
      for (final package in packages)
        if (!results.issueMap.containsKey(package.packageIdentity.name))
          _formatOk(tick, package.packageIdentity.name, results),
      for (final entry in results.issueMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final line in entry.value.split('\n')) '      $line',
      ],
    ].join('\n');
  }

  String _formatOk(String tick, String name, _CheckResult results) {
    final threshold = results.effectiveThresholds[name];
    return '  $tick $name: OK (>= $threshold%)';
  }
}

/// Result of checking every package: the error for each one that failed,
/// and the threshold actually enforced for each one that passed.
typedef _CheckResult = ({
  Map<String, String> issueMap,
  Map<String, double> effectiveThresholds,
});

class CoverageBatchException extends CommandExecutionException {
  @override
  final String message;

  const CoverageBatchException(this.message);
}
