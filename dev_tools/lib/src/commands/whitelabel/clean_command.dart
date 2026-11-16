import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';

class CleanCommand extends Command<void> {
  static const String commandName = 'clean';
  static const String commandDescription =
      'Delete artifacts matched by the project white-label exclusions.';
  static const String projectOption = 'project';

  final CleanProjectArtifacts _cleanProjectArtifacts;

  CleanCommand({CleanProjectArtifacts? cleanProjectArtifacts})
      : _cleanProjectArtifacts =
            cleanProjectArtifacts ?? CleanProjectArtifacts() {
    argParser.addOption(
      projectOption,
      abbr: 'p',
      help: 'Project directory (default: current project root).',
    );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.isNotEmpty) {
      usageException('This command does not accept positional arguments.');
    }
    final removed = await _cleanProjectArtifacts(
      argResults![projectOption] as String?,
    );
    if (removed.isEmpty) {
      print('No configured artifacts found.');
      return;
    }
    print('Removed ${removed.length} configured artifact(s):');
    for (final path in removed) {
      print('- $path');
    }
  }
}
