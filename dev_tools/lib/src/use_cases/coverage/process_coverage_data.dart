import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';
import 'package:dev_tools/src/utils/logger.dart';

class ProcessCoverageDataWithLcov {
  final FindProjectRoot _findProjectRoot;
  final CmdInstallationChecker _cmdInstallationChecker;
  final ReadCoverageConfig _readCoverageConfig;
  final Logger _logger;

  const ProcessCoverageDataWithLcov({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
    ReadCoverageConfig readCoverageConfig = const ReadCoverageConfig(),
    Logger logger = const ConsoleLogger(),
  })  : _findProjectRoot = findProjectRoot,
        _cmdInstallationChecker = cmdInstallationChecker,
        _readCoverageConfig = readCoverageConfig,
        _logger = logger;

  /// Filters lcov coverage data using exclusion patterns.
  ///
  /// Params:
  /// - `exclusions`: lcov removal patterns relative to the project root
  ///   (e.g. 'lib/api/**'). When omitted, falls back to the project's own
  ///   `dev_tools_coverage_config.yaml` `exclude` list (see
  ///   [ReadCoverageConfig]).
  ///
  /// Returns: nothing (void); writes the filtered data back to
  /// coverage/lcov.info.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when lcov is not installed.
  /// - [ProjectRootNotFoundException] when no project root can be found.
  /// - [LcovFilteringException] when `lcov --remove` exits with a non-zero
  ///   code.
  Future<void> call({List<String> exclusions = const []}) async {
    final root = await _findProjectRoot();
    if (!await _cmdInstallationChecker('lcov')) {
      throw const CommandNotFoundException(['lcov']);
    }

    var effectiveExclusions = exclusions;
    if (effectiveExclusions.isEmpty) {
      final config = await _readCoverageConfig(root);
      effectiveExclusions = config.exclude;
    }

    final result = await Process.run('lcov', [
      '--remove',
      '$root/coverage/lcov.info',
      '--output-file',
      '$root/coverage/lcov.info',
      ...effectiveExclusions,
      // A pattern that matches nothing is a hard error on newer lcov
      // versions otherwise.
      '--ignore-errors',
      'unused,empty',
    ]);
    if (result.exitCode != 0) {
      throw LcovFilteringException(
        'Error(${result.exitCode}): lcov --remove failed.\n${result.stderr}',
      );
    }

    _logger.info('Coverage data filtered at coverage/lcov.info.');
  }
}

class LcovFilteringException extends CommandExecutionException {
  @override
  final String message;

  const LcovFilteringException(this.message);
}
