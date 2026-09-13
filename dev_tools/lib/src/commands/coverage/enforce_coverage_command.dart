import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_threshold.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';

class EnforceCoverageCommand extends Command<void> {
  static const String commandName = 'enforce';
  static const String lcovFileOption = 'lcov-file';
  static const String thresholdOption = 'threshold';
  static const String commandDescription =
      'Enforce the coverage threshold against an lcov file (default 100%). '
      'The lcov file path is relative to the project root (default '
      'coverage/lcov.info) and the threshold is a percentage.';

  final EnforceCoverageThreshold _enforceCoverage;
  final FindProjectRoot _findProjectRoot;

  EnforceCoverageCommand({
    EnforceCoverageThreshold checkCoverage = const EnforceCoverageThreshold(),
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
  })  : _enforceCoverage = checkCoverage,
        _findProjectRoot = findProjectRoot {
    argParser
      ..addOption(
        lcovFileOption,
        defaultsTo: 'coverage/lcov.info',
        help: 'Path to the lcov file, relative to the project root.',
      )
      ..addOption(
        thresholdOption,
        defaultsTo: '100',
        help: 'Coverage percentage.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final lcovFile = argResults![lcovFileOption] as String;
    final threshold = double.parse(argResults![thresholdOption] as String);
    final projectRoot = await _findProjectRoot();
    return _enforceCoverage(
      projectRoot: projectRoot,
      lcovFile: lcovFile,
      threshold: threshold,
    );
  }
}
