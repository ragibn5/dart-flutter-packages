// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/exceptions/coverage_threshold_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/utils/logger.dart';

class EnforceCoverageThreshold {
  final Logger _logger;
  final CalculateCoverage _calculateCoverage;

  const EnforceCoverageThreshold({
    Logger logger = const ConsoleLogger(),
    CalculateCoverage coverageUtils = const CalculateCoverage(),
  })  : _logger = logger,
        _calculateCoverage = coverageUtils;

  /// Enforces a minimum line coverage threshold on an lcov file.
  ///
  /// Params:
  /// - `projectRoot`: absolute path to the project root.
  /// - `lcovFile`: path to the lcov file, relative to `projectRoot`
  ///   (default 'coverage/lcov.info').
  /// - `threshold`: required coverage percentage (default 100).
  ///
  /// Returns: nothing (void); logs the result via this instance's [Logger].
  ///
  /// Throws:
  /// - [CoverageThresholdException] when coverage is below the
  ///   required threshold.
  /// - [CoverageCalculationException] when `lcovFile` is missing or
  ///   unparsable (see [CalculateCoverage]).
  Future<void> call({
    required String projectRoot,
    String lcovFile = 'coverage/lcov.info',
    double threshold = 100,
  }) async {
    final pct = await _calculateCoverage(lcovFile, projectRoot);
    if (pct < threshold) {
      throw CoverageThresholdException(
        'ERROR: Coverage $pct% is below required ${_fmt(threshold)}%.\n'
        '       Make sure you ran the tests with coverage and processed the coverage data first for fresh coverage data.',
      );
    }
    _logger.info('Coverage meets required ${_fmt(threshold)}%.');
  }

  String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
