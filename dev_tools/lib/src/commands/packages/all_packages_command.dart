// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_all_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';

class AllPackagesCommand extends Command<void> {
  static const String commandName = 'all';

  static const String commandDescription =
      'Print the repo-root-relative path of every package in the repository, one per line.';

  static const String skipPathOption = 'skip-path';

  final GetRepoRootPath _getRepoRootPath;
  final FindAllPackages _findAllPackages;

  AllPackagesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    FindAllPackages findAllPackages = const FindAllPackages(),
  })  : _getRepoRootPath = getRepoRootPath,
        _findAllPackages = findAllPackages {
    argParser.addMultiOption(
      skipPathOption,
      abbr: 's',
      help: 'Repo-root-relative path prefix of a whole package to skip '
          'entirely (e.g. app_template).',
    );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    final packages = await _findAllPackages(
      repoRoot: repoRoot,
      skipPaths: argResults![skipPathOption] as List<String>,
    );

    for (final package in packages) {
      print(package.repoRootRelativePath);
    }
  }
}
