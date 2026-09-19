import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Runs the interactive white-label setup menu for one copied project.
class RunWhitelabelSetup {
  final CleanProjectArtifacts _cleanProjectArtifacts;
  final Prompter _prompter;

  RunWhitelabelSetup({
    CleanProjectArtifacts? cleanProjectArtifacts,
    Prompter prompter = const ConsolePrompter(),
  })  : _cleanProjectArtifacts =
            cleanProjectArtifacts ?? CleanProjectArtifacts(),
        _prompter = prompter;

  /// Shows setup actions until the user exits or input ends.
  Future<void> call(String projectPath) async {
    while (true) {
      _prompter.write(
        '\n[White-label setup: $projectPath]\n'
        '1) Project cleanup\n'
        '2) Exit\n'
        'Select a step [1-2]: ',
      );
      switch (_prompter.readLine()?.trim()) {
        case '1':
          await _cleanProjectArtifacts(projectPath);
        case '2':
        case null:
          return;
        default:
          _prompter.write('Invalid choice.\n');
      }
    }
  }
}
