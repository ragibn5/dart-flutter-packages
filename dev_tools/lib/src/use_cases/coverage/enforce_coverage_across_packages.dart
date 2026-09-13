import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Orchestrates running every package's tests with coverage and enforcing a
/// minimum line-coverage threshold on each.
///
/// Runs independently per package — one failing doesn't stop the rest —
/// then reports a per-package summary and fails the batch (via
/// [CoverageBatchException]) if any package failed.
class EnforceCoverageAcrossPackages {
  final Logger _logger;
  final FindPackages _findPackages;
  final CalculateCoverage _calculateCoverage;
  final RunPackageTestsWithCoverage _runPackageTests;

  const EnforceCoverageAcrossPackages({
    Logger logger = const ConsoleLogger(),
    FindPackages findPackages = const FindPackages(),
    CalculateCoverage calculateCoverage = const CalculateCoverage(),
    RunPackageTestsWithCoverage runPackageTests =
        const RunPackageTestsWithCoverage(),
  })  : _logger = logger,
        _findPackages = findPackages,
        _calculateCoverage = calculateCoverage,
        _runPackageTests = runPackageTests;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root to scan.
  /// - `threshold`: required coverage percentage (default 100).
  /// - `exclude`: repo-root-relative path prefixes to skip entirely (e.g.
  ///   `app_template`, which has its own dedicated CI coverage flow).
  ///
  /// Returns: nothing (void) when every package meets [threshold].
  ///
  /// Throws:
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  /// - [CoverageBatchException] listing every package that failed its tests
  ///   or fell below [threshold], once every package has been checked.
  Future<void> call({
    required String repoRoot,
    double threshold = 100,
    List<String> exclude = const [],
  }) async {
    final packages = await _logger.withGroupedLog(
      'Scanning for packages...',
      (logger) => _extractPackages(repoRoot, exclude, logger),
    );

    final issueMap = await _checkPackages(repoRoot, packages, threshold);
    _logger.info(
      'Coverage report for ${packages.length} package(s):\n'
      '${_buildSummary(packages, issueMap)}',
    );

    if (issueMap.isNotEmpty) {
      throw CoverageBatchException(
        '${issueMap.length} package(s) failed coverage enforcement.',
      );
    }
  }

  Future<List<ValidLocalPackageInfo>> _extractPackages(
    String repoRoot,
    List<String> exclude,
    Logger logger,
  ) async {
    final foundPackages = await _findPackages(repoRoot: repoRoot);
    final validPackages = foundPackages
        .whereType<ValidLocalPackageInfo>()
        .where((pkg) => !_isExcluded(pkg.repoRootRelativePath, exclude))
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

  bool _isExcluded(String repoRootRelativePath, List<String> exclude) =>
      exclude.any(
        (prefix) =>
            repoRootRelativePath == prefix ||
            repoRootRelativePath.startsWith('$prefix/'),
      );

  Future<Map<String, String>> _checkPackages(
    String repoRoot,
    List<ValidLocalPackageInfo> packages,
    double threshold,
  ) async {
    final issueMap = <String, String>{};
    for (var i = 0; i < packages.length; ++i) {
      final package = packages[i];
      final name = package.packageIdentity.name;
      await _logger.withGroupedLog(
        '[${i + 1}/${packages.length}] Checking $name ...',
        (logger) async {
          try {
            await _checkPackage(repoRoot, package, threshold);
          } catch (e) {
            issueMap[name] = e.toString();
          }
        },
      );
    }
    return issueMap;
  }

  Future<void> _checkPackage(
    String repoRoot,
    ValidLocalPackageInfo package,
    double threshold,
  ) async {
    final packagePath = p.join(repoRoot, package.repoRootRelativePath);
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
    Map<String, String> issueMap,
  ) {
    final tick = stdout.supportsAnsiEscapes ? _greenTick : '✓';
    final cross = stdout.supportsAnsiEscapes ? _redCross : '✗';
    return [
      for (final package in packages)
        if (!issueMap.containsKey(package.packageIdentity.name))
          '  $tick ${package.packageIdentity.name}: OK',
      for (final entry in issueMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final line in entry.value.split('\n')) '      $line',
      ],
    ].join('\n');
  }
}

class CoverageBatchException extends CommandExecutionException {
  @override
  final String message;

  const CoverageBatchException(this.message);
}

class CoverageThresholdException extends CommandExecutionException {
  @override
  final String message;

  const CoverageThresholdException(this.message);
}
