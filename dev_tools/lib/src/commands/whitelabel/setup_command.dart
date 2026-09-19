import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_whitelabel_setup.dart';

/// Copies a template into `<path>` and runs white-label actions against it,
/// or, when `<path>` already exists, runs them directly against it instead
/// (no copy).
class SetupCommand extends Command<void> {
  static const String commandName = 'setup';
  static const String commandDescription =
      'Create a white-label project (or run in-place on an existing one) '
      'and open its interactive setup menu.';
  static const String templateOption = 'template';

  final CopyTemplateProject _copyTemplateProject;
  final RunWhitelabelSetup _runWhitelabelSetup;
  final ConfirmYesNo _confirmYesNo;

  SetupCommand({
    CopyTemplateProject? copyTemplateProject,
    RunWhitelabelSetup? runWhitelabelSetup,
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
  })  : _copyTemplateProject = copyTemplateProject ?? CopyTemplateProject(),
        _runWhitelabelSetup = runWhitelabelSetup ?? RunWhitelabelSetup(),
        _confirmYesNo = confirmYesNo {
    argParser.addOption(
      templateOption,
      abbr: 't',
      help: 'Template project directory, used only when <path> does not '
          'already exist (default: current project root).',
    );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.length != 1) {
      usageException('Expected exactly one positional argument <path>.');
    }
    final path = argResults!.rest.single;

    String? projectPath;
    if (Directory(path).existsSync()) {
      projectPath = await _resolveInPlaceProject(path);
    } else {
      projectPath = await _copyTemplateProject(
        template: argResults![templateOption] as String?,
        destination: path,
      );
    }
    if (projectPath == null) return;

    await _runWhitelabelSetup(projectPath);
  }

  Future<String?> _resolveInPlaceProject(String path) async {
    print(
      "⚠️  '$path' already exists — running setup in-place on it instead "
      'of copying a template. This modifies the project directly.',
    );
    if (!await _confirmYesNo('Continue?')) {
      print('Aborted.');
      return null;
    }
    return Directory(path).absolute.path;
  }
}
