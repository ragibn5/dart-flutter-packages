import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/use_cases/whitelabel/ensure_firebase_account.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Runs the interactive white-label setup menu for one copied project.
class RunWhitelabelSetup {
  final CleanProjectArtifacts _cleanProjectArtifacts;
  final RunFirebaseSetup _runFirebaseSetup;
  final Prompter _prompter;

  RunWhitelabelSetup({
    CleanProjectArtifacts? cleanProjectArtifacts,
    RunFirebaseSetup? runFirebaseSetup,
    Prompter prompter = const ConsolePrompter(),
  })  : _cleanProjectArtifacts =
            cleanProjectArtifacts ?? CleanProjectArtifacts(),
        _runFirebaseSetup = runFirebaseSetup ??
            RunFirebaseSetup(
              confirmYesNo: ConfirmYesNo(prompter: prompter),
              promptWithDefault: PromptWithDefault(prompter: prompter),
              ensureFirebaseAccount: EnsureFirebaseAccount(prompter: prompter),
            ),
        _prompter = prompter;

  /// Shows setup actions until the user exits or input ends.
  Future<void> call(String projectPath) async {
    while (true) {
      _prompter.write(
        '\n[White-label setup: $projectPath]\n'
        '1) Project cleanup\n'
        '2) Firebase project setup\n'
        '3) Exit\n'
        'Select a step [1-3]: ',
      );
      switch (_prompter.readLine()?.trim()) {
        case '1':
          await _cleanProjectArtifacts(projectPath);
        case '2':
          await _runFirebaseSetupStep(projectPath);
        case '3':
        case null:
          return;
        default:
          _prompter.write('Invalid choice.\n');
      }
    }
  }

  Future<void> _runFirebaseSetupStep(String projectPath) async {
    const flavors = RunFirebaseSetup.validFlavors;
    _prompter.write('Enter flavor (${flavors.join('/')}): ');
    final flavor = (_prompter.readLine() ?? '').trim();
    if (!flavors.contains(flavor)) {
      _prompter.write('Invalid flavor.\n');
      return;
    }

    try {
      await _runFirebaseSetup(projectPath, flavor);
    } on FirebaseSetupException catch (e) {
      _prompter.write('$e\n');
    }
  }
}
