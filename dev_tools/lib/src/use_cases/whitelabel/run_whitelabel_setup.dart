import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/use_cases/whitelabel/ensure_firebase_account.dart';
import 'package:dev_tools/src/use_cases/whitelabel/finalize_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_dart_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_platform_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_app_name_change_guide.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_final_todos.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_launcher_icon_change_guide.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_splash_icon_change_guide.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Runs the interactive white-label setup menu for one copied project.
class RunWhitelabelSetup {
  final CleanProjectArtifacts _cleanProjectArtifacts;
  final RenameDartPackage _renameDartPackage;
  final RenamePlatformPackage _renamePlatformPackage;
  final ShowAppNameChangeGuide _showAppNameChangeGuide;
  final ShowLauncherIconChangeGuide _showLauncherIconChangeGuide;
  final ShowSplashIconChangeGuide _showSplashIconChangeGuide;
  final RunFirebaseSetup _runFirebaseSetup;
  final FinalizeProject _finalizeProject;
  final ReadWhitelabelConfig _readWhitelabelConfig;
  final Prompter _prompter;

  RunWhitelabelSetup({
    CleanProjectArtifacts? cleanProjectArtifacts,
    RenameDartPackage? renameDartPackage,
    RenamePlatformPackage? renamePlatformPackage,
    ShowAppNameChangeGuide? showAppNameChangeGuide,
    ShowLauncherIconChangeGuide? showLauncherIconChangeGuide,
    ShowSplashIconChangeGuide? showSplashIconChangeGuide,
    RunFirebaseSetup? runFirebaseSetup,
    FinalizeProject? finalizeProject,
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
    Prompter prompter = const ConsolePrompter(),
  })  : _cleanProjectArtifacts =
            cleanProjectArtifacts ?? CleanProjectArtifacts(),
        _renameDartPackage =
            renameDartPackage ?? RenameDartPackage(prompter: prompter),
        _renamePlatformPackage =
            renamePlatformPackage ?? RenamePlatformPackage(prompter: prompter),
        _showAppNameChangeGuide = showAppNameChangeGuide ??
            ShowAppNameChangeGuide(prompter: prompter),
        _showLauncherIconChangeGuide = showLauncherIconChangeGuide ??
            ShowLauncherIconChangeGuide(
              prompter: prompter,
              confirmYesNo: ConfirmYesNo(prompter: prompter),
            ),
        _showSplashIconChangeGuide = showSplashIconChangeGuide ??
            ShowSplashIconChangeGuide(
              prompter: prompter,
              confirmYesNo: ConfirmYesNo(prompter: prompter),
            ),
        _runFirebaseSetup = runFirebaseSetup ??
            RunFirebaseSetup(
              confirmYesNo: ConfirmYesNo(prompter: prompter),
              promptWithDefault: PromptWithDefault(prompter: prompter),
              ensureFirebaseAccount: EnsureFirebaseAccount(prompter: prompter),
            ),
        _finalizeProject = finalizeProject ??
            FinalizeProject(
              prompter: prompter,
              showFinalTodos: ShowFinalTodos(prompter: prompter),
            ),
        _readWhitelabelConfig = readWhitelabelConfig,
        _prompter = prompter;

  /// Shows setup actions until the user exits or input ends.
  Future<void> call(String projectPath) async {
    while (true) {
      _prompter.write(
        '\n[White-label setup: $projectPath]\n'
        '1) Project cleanup\n'
        '2) Dart package name replacement\n'
        '3) Platform package name replacement\n'
        '4) App name change guide\n'
        '5) Launcher icon change guide\n'
        '6) Splash icon change guide\n'
        '7) Firebase project setup\n'
        '8) Done - finalize setup\n'
        '9) Exit\n'
        'Select a step [1-9]: ',
      );
      switch (_prompter.readLine()?.trim()) {
        case '1':
          await _cleanProjectArtifacts(projectPath);
        case '2':
          await _renameDartPackage(projectPath);
        case '3':
          await _renamePlatformPackage(projectPath);
        case '4':
          await _showAppNameChangeGuide(projectPath);
        case '5':
          await _showLauncherIconChangeGuide(projectPath);
        case '6':
          await _showSplashIconChangeGuide(projectPath);
        case '7':
          await _runFirebaseSetupStep(projectPath);
        case '8':
          await _finalizeProject(projectPath);
        case '9':
        case null:
          return;
        default:
          _prompter.write('Invalid choice.\n');
      }
    }
  }

  Future<void> _runFirebaseSetupStep(String projectPath) async {
    final flavors = (await _readWhitelabelConfig(projectPath)).flavors;
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
