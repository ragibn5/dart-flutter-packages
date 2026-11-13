import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';

class CalculateCoverage {
  /// A line of lcov data, such as `SF:lib/a.dart` or `DA:3,1`.
  static final _lcovRecord = RegExp(r'^[A-Z]+:');

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
  /// Returns: the rounded line coverage percentage; 100 when the file holds
  /// no measurable lines, as nothing is uncovered then.
  ///
  /// Throws:
  /// - [CoverageCalculationException] when the file is missing or isn't
  ///   lcov data.
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
      if (line.trim().isEmpty || line == 'end_of_record') {
        continue;
      }
      if (!_lcovRecord.hasMatch(line)) {
        throw const CoverageCalculationException(
          'Could not parse coverage data.',
        );
      }
      if (line.startsWith('LF:')) {
        found += int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        hit += int.parse(line.substring(3));
      }
    }

    // Nothing left to measure, such as a package of interfaces only, or one
    // whose every file is excluded: nothing is uncovered.
    if (found == 0) {
      return 100;
    }

    return (hit / found * 100).round();
  }
}

class CoverageCalculationException extends CommandExecutionException {
  @override
  final String message;

  const CoverageCalculationException(this.message);
}
