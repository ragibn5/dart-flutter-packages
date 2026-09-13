import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';

class CalculateCoverage {
  final FindProjectRoot _findProjectRoot;

  const CalculateCoverage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
  }) : _findProjectRoot = findProjectRoot;

  /// Computes the line coverage reported in an lcov file.
  ///
  /// Params:
  /// - `lcovFile`: path to the lcov file, relative to [projectRoot] (or the
  ///   project root resolved from the current working directory).
  /// - `projectRoot`: absolute path to the project root (optional).
  ///
  /// Returns: the rounded line coverage percentage.
  ///
  /// Throws:
  /// - [CoverageCalculationException] when the file is missing or its
  ///   summary cannot be parsed.
  /// - [ProjectRootNotFoundException] when `projectRoot` is omitted and no
  ///   project root can be found.
  Future<int> call(String lcovFile, [String? projectRoot]) async {
    final root = projectRoot ?? await _findProjectRoot();
    final file = File('$root/$lcovFile');
    if (!file.existsSync()) {
      throw CoverageCalculationException(
        'coverage file not found: $lcovFile.',
      );
    }

    var found = 0;
    var hit = 0;
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('LF:')) {
        found += int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        hit += int.parse(line.substring(3));
      }
    }

    if (found == 0) {
      throw const CoverageCalculationException(
        'Could not parse coverage data.',
      );
    }

    return (hit / found * 100).round();
  }
}

class CoverageCalculationException extends CommandExecutionException {
  @override
  final String message;

  const CoverageCalculationException(this.message);
}
