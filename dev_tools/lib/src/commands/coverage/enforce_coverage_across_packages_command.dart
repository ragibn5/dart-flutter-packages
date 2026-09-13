import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';

class EnforceCoverageAcrossPackagesCommand extends Command<void> {
  static const String commandName = 'coverage';
  static const String commandDescription =
      "Run every touched package's tests with coverage (or every package, "
      'with --all) and enforce a minimum line-coverage threshold (default '
      '100%) on each.\n\n'
      'Notes:\n'
      "- A package's own .coverage_exclude file (lcov glob patterns, one "
      'per line, # comments allowed) filters its lcov data before the '
      'threshold check.\n'
      '- Not to be confused with --skip-path below, which skips a whole '
      'package rather than files within one.';

  static const String fromOption = 'from';
  static const String toOption = 'to';
  static const String thresholdOption = 'threshold';
  static const String skipPathOption = 'skip-path';
  static const String allFlag = 'all';

  final GetRepoRootPath _getRepoRootPath;
  final EnforceCoverageAcrossPackages _enforceCoverageAcrossPackages;

  EnforceCoverageAcrossPackagesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    EnforceCoverageAcrossPackages enforceCoverageAcrossPackages =
        const EnforceCoverageAcrossPackages(),
  })  : _getRepoRootPath = getRepoRootPath,
        _enforceCoverageAcrossPackages = enforceCoverageAcrossPackages {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD^',
        help: 'The branch state before this change '
            '(default: the previous commit).',
      )
      ..addOption(
        toOption,
        defaultsTo: 'HEAD',
        help: 'The branch state after this change '
            '(default: the currently checked-out commit).',
      )
      ..addOption(
        thresholdOption,
        defaultsTo: '100',
        help: 'Coverage percentage.',
      )
      ..addMultiOption(
        skipPathOption,
        abbr: 's',
        help: 'Repo-root-relative path prefix of a whole package to skip '
            'entirely (e.g. app_template).',
      )
      ..addFlag(
        allFlag,
        negatable: false,
        help: 'Check every found package, ignoring --from/--to entirely '
            '(no diffing happens at all).',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    final threshold =
        double.tryParse(argResults![thresholdOption] as String) ?? 100.0;
    await _enforceCoverageAcrossPackages(
      repoRoot: repoRoot,
      fromRef: argResults![fromOption] as String,
      toRef: argResults![toOption] as String,
      threshold: threshold,
      skipPaths: argResults![skipPathOption] as List<String>,
      all: argResults!.flag(allFlag),
    );
  }
}
