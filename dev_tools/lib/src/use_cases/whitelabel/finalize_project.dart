import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_final_todos.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Performs the final cleanup and dependency fetch for a white-label
/// project, then prints its remaining manual TODOs.
class FinalizeProject {
  final Prompter _prompter;
  final CleanProjectArtifacts _cleanProjectArtifacts;
  final FindFvmAwareFlutterCommand _findFlutterCommand;
  final ShowFinalTodos _showFinalTodos;

  FinalizeProject({
    Prompter prompter = const ConsolePrompter(),
    CleanProjectArtifacts? cleanProjectArtifacts,
    FindFvmAwareFlutterCommand findFlutterCommand =
        const FindFvmAwareFlutterCommand(),
    ShowFinalTodos showFinalTodos = const ShowFinalTodos(),
  })  : _prompter = prompter,
        _cleanProjectArtifacts =
            cleanProjectArtifacts ?? CleanProjectArtifacts(),
        _findFlutterCommand = findFlutterCommand,
        _showFinalTodos = showFinalTodos;

  /// Deletes configured artifacts (see [CleanProjectArtifacts]), runs
  /// `pub get` via the fvm-aware Flutter command, then prints the remaining
  /// manual TODOs (see [ShowFinalTodos]) for [projectPath].
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [CommandNotFoundException] when neither fvm nor a system-wide
  ///   Flutter is installed (see [FindFvmAwareFlutterCommand]).
  Future<void> call(String projectPath) async {
    _prompter.write('▶️ Performing final cleanup and other operations...\n');
    await _cleanProjectArtifacts(projectPath);

    _prompter.write('\nRunning pub get ...\n');
    final flutterCommand = (await _findFlutterCommand()).split(RegExp(r'\s+'));
    final exitCode = await InteractiveProcessRunner(
      executable: flutterCommand.first,
      arguments: [...flutterCommand.skip(1), 'pub', 'get'],
      workingDirectory: projectPath,
    ).run();
    if (exitCode != 0) {
      _prompter.write(
        '\n⚠️ pub get failed (exit code $exitCode). This is often the '
        "template's dev_tools dev_dependency, which points at a "
        'monorepo-relative ../dev_tools path — see the TODOs below.\n',
      );
    }

    _showFinalTodos(projectPath);
  }
}
