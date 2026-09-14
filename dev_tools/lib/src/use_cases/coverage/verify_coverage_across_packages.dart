import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/exceptions/coverage_threshold_exception.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/resolve_local_packages.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

/// Orchestrates running a given set of packages' tests with coverage and
/// enforcing a minimum line-coverage threshold on each.
///
/// By default runs independently per package — one failing doesn't stop
/// the rest — then reports a per-package summary and fails the batch (via
/// [CoverageBatchException]) if any package failed. Pass `failFast: true`
/// to stop at the first package that fails instead.
class VerifyCoverageAcrossPackages {
  final Logger _logger;
  final ResolveLocalPackages _resolveLocalPackages;
  final CalculateCoverage _calculateCoverage;
  final RunPackageTestsWithCoverage _runPackageTests;
  final ReadCoverageConfig _readCoverageConfig;

  const VerifyCoverageAcrossPackages({
    Logger logger = const ConsoleLogger(),
    ResolveLocalPackages resolveLocalPackages = const ResolveLocalPackages(),
    CalculateCoverage calculateCoverage = const CalculateCoverage(),
    RunPackageTestsWithCoverage runPackageTests =
        const RunPackageTestsWithCoverage(),
    ReadCoverageConfig readCoverageConfig = const ReadCoverageConfig(),
  })  : _logger = logger,
        _resolveLocalPackages = resolveLocalPackages,
        _calculateCoverage = calculateCoverage,
        _runPackageTests = runPackageTests,
        _readCoverageConfig = readCoverageConfig;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `packagePaths`: repo-root-relative paths of the packages to check
  ///   (e.g. `packages/foo`) — every entry must resolve to a package with a
  ///   valid pubspec.yaml under [repoRoot].
  /// - `threshold`: required coverage percentage (default 100) — a
  ///   package's own `dev_tools_coverage_config.yaml` may override this
  ///   for itself.
  /// - `failFast`: when `true`, stop checking as soon as one package fails
  ///   instead of checking every given package (default `false`).
  ///
  /// Returns: nothing (void) when every checked package meets its
  /// (possibly overridden) threshold.
  ///
  /// Throws:
  /// - [PackageNotFoundException] when a package path doesn't resolve to a
  ///   package with a valid pubspec.yaml.
  /// - [CoverageBatchException] listing every package that failed its tests
  ///   or fell below [globalThreshold] (or package specific override) —
  ///   just the first one when [failFast] is `true`.
  Future<void> call({
    required String repoRoot,
    required List<String> packagePaths,
    double globalThreshold = 100,
    bool failFast = false,
  }) async {
    final packagesToCheck = await _logger.withGroupedLog(
      'Resolving packages...',
      (logger) => _resolvePackages(repoRoot, packagePaths, logger),
    );

    final results = await _checkPackages(
      repoRoot,
      globalThreshold,
      packagesToCheck,
      failFast: failFast,
    );
    _logger.info(
      'Coverage report for ${results.checkedPackages.length}/'
      '${packagesToCheck.length} package(s) checked:\n'
      '${_buildSummary(results)}',
    );

    if (results.issueMap.isNotEmpty) {
      throw CoverageBatchException(
        '${results.issueMap.length} package(s) failed coverage enforcement.',
      );
    }
  }

  Future<List<ValidLocalPackageInfo>> _resolvePackages(
    String repoRoot,
    List<String> packagePaths,
    Logger logger,
  ) async {
    final packages = await _resolveLocalPackages(
      repoRoot: repoRoot,
      packagePaths: packagePaths,
    );

    logger.info('Resolved ${packages.length} package(s).');

    return packages;
  }

  Future<_CheckResult> _checkPackages(
    String repoRoot,
    double globalThreshold,
    List<ValidLocalPackageInfo> packages, {
    required bool failFast,
  }) async {
    final issueMap = <String, String>{};
    final effectiveThresholds = <String, double>{};
    final checkedPackages = <ValidLocalPackageInfo>[];
    for (var i = 0; i < packages.length; ++i) {
      final package = packages[i];
      final name = package.packageIdentity.name;
      final packagePath = p.join(repoRoot, package.repoRootRelativePath);

      // Read upfront (can't fail) so every checked package's threshold is
      // known regardless of whether its check below passes or throws.
      final config = await _readCoverageConfig(packagePath);
      effectiveThresholds[name] = config.threshold ?? globalThreshold;
      checkedPackages.add(package);

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

      if (failFast && issueMap.isNotEmpty) break;
    }
    return (
      issueMap: issueMap,
      effectiveThresholds: effectiveThresholds,
      checkedPackages: checkedPackages,
    );
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

  String _buildSummary(_CheckResult results) {
    const tick = '✅';
    const cross = '❌';
    return [
      for (final package in results.checkedPackages)
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

/// Result of checking packages — all of them, or only up to (and
/// including) the first failure when `failFast` was requested: which
/// packages were actually checked, the error for each one that failed,
/// and the threshold enforced for each one that passed.
typedef _CheckResult = ({
  Map<String, String> issueMap,
  Map<String, double> effectiveThresholds,
  List<ValidLocalPackageInfo> checkedPackages,
});

class CoverageBatchException extends CommandExecutionException {
  @override
  final String message;

  const CoverageBatchException(this.message);
}
