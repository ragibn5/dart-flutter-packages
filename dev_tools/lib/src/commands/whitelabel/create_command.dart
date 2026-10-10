import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';

/// Copies a template project to a new, independent destination.
class CreateCommand extends Command<void> {
  static const String commandName = 'create';
  static const String commandDescription =
      'Copy a Flutter template to a new white-label project directory.';
  static const String templateOption = 'template';
  static const String forceFlag = 'force';

  final CopyTemplateProject _copyTemplateProject;

  CreateCommand({CopyTemplateProject? copyTemplateProject})
      : _copyTemplateProject = copyTemplateProject ?? CopyTemplateProject() {
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
    final destination = argResults!.rest;
    if (destination.length != 1) {
      usageException('Expected exactly one positional argument <destination>.');
    }

    final project = await _copyTemplateProject(
      template: argResults![templateOption] as String?,
      destination: destination.single,
      allowExistingEmptyDirectory: argResults![forceFlag] as bool,
    );
    print('White-label project created at: $project');
    print('Next: cd "$project" and run the configuration commands there.');
  }
}
