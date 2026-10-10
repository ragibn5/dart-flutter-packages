import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';

/// Configures Firebase for one flavor of an existing project, without
/// copying a template first.
class FirebaseCommand extends Command<void> {
  static const String commandName = 'firebase';
  static const String commandDescription =
      'Configure Firebase for one flavor of an existing project.';
  static const String projectOption = 'project';

  final FindProjectRoot _findProjectRoot;
  final RunFirebaseSetup _runFirebaseSetup;

  FirebaseCommand({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    RunFirebaseSetup? runFirebaseSetup,
  })  : _findProjectRoot = findProjectRoot,
        _runFirebaseSetup = runFirebaseSetup ?? const RunFirebaseSetup() {
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
    if (argResults!.rest.length > 1) {
      usageException(
        'Expected at most one positional argument <flavor>. Valid flavors '
        "are read from the project's dev_tools_whitelabel_config.yaml, or "
        'omit <flavor> entirely for a flavorless project (uses "default").',
      );
    }

    final projectPath = await _findProjectRoot(
      argResults![projectOption] as String?,
    );
    final flavor =
        argResults!.rest.isEmpty ? 'default' : argResults!.rest.single;
    await _runFirebaseSetup(projectPath, flavor);
  }
}
