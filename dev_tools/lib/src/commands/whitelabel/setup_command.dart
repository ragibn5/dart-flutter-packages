import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_whitelabel_setup.dart';

/// Copies a template, then runs white-label actions against the copied project.
class SetupCommand extends Command<void> {
  static const String commandName = 'setup';
  static const String commandDescription =
      'Create a white-label project and open its interactive setup menu.';
  static const String templateOption = 'template';
  static const String forceFlag = 'force';

  final CopyTemplateProject _copyTemplateProject;
  final RunWhitelabelSetup _runWhitelabelSetup;

  SetupCommand({
    CopyTemplateProject? copyTemplateProject,
    RunWhitelabelSetup? runWhitelabelSetup,
  })  : _copyTemplateProject = copyTemplateProject ?? CopyTemplateProject(),
        _runWhitelabelSetup = runWhitelabelSetup ?? RunWhitelabelSetup() {
    argParser
      ..addOption(
        templateOption,
        abbr: 't',
        help: 'Template project directory (default: current project root).',
      )
      ..addFlag(
        forceFlag,
        help: 'Allow an existing, empty destination directory.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one positional argument <destination>.');
    }
    final projectPath = await _copyTemplateProject(
      template: argResults![templateOption] as String?,
      destination: argResults!.rest.single,
      allowExistingEmptyDirectory: argResults![forceFlag] as bool,
    );
    await _runWhitelabelSetup(projectPath);
  }
}
