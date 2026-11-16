import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/use_cases/whitelabel/finalize_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_dart_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_platform_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_whitelabel_setup.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_app_name_change_guide.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_launcher_icon_change_guide.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_splash_icon_change_guide.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_config_exception.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockCleanProjectArtifacts extends Mock
    implements CleanProjectArtifacts {}

class _MockRenameDartPackage extends Mock implements RenameDartPackage {}

class _MockRenamePlatformPackage extends Mock
    implements RenamePlatformPackage {}

class _MockShowAppNameChangeGuide extends Mock
    implements ShowAppNameChangeGuide {}

class _MockShowLauncherIconChangeGuide extends Mock
    implements ShowLauncherIconChangeGuide {}

class _MockShowSplashIconChangeGuide extends Mock
    implements ShowSplashIconChangeGuide {}

class _MockRunFirebaseSetup extends Mock implements RunFirebaseSetup {}

class _MockFinalizeProject extends Mock implements FinalizeProject {}

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

const _project = '/project';

void main() {
  late _MockCleanProjectArtifacts cleanProjectArtifacts;
  late _MockRenameDartPackage renameDartPackage;
  late _MockRenamePlatformPackage renamePlatformPackage;
  late _MockShowAppNameChangeGuide showAppNameChangeGuide;
  late _MockShowLauncherIconChangeGuide showLauncherIconChangeGuide;
  late _MockShowSplashIconChangeGuide showSplashIconChangeGuide;
  late _MockRunFirebaseSetup runFirebaseSetup;
  late _MockFinalizeProject finalizeProject;
  late _MockReadWhitelabelConfig readWhitelabelConfig;

  void useFlavors(List<String> flavors) =>
      when(() => readWhitelabelConfig(any())).thenAnswer(
        (_) async => WhitelabelConfig(
          exclude: const [],
          flavors: flavors,
          firebase: const {},
          firebaseOutputPaths: null,
        ),
      );

  setUp(() {
    cleanProjectArtifacts = _MockCleanProjectArtifacts();
    renameDartPackage = _MockRenameDartPackage();
    renamePlatformPackage = _MockRenamePlatformPackage();
    showAppNameChangeGuide = _MockShowAppNameChangeGuide();
    showLauncherIconChangeGuide = _MockShowLauncherIconChangeGuide();
    showSplashIconChangeGuide = _MockShowSplashIconChangeGuide();
    runFirebaseSetup = _MockRunFirebaseSetup();
    finalizeProject = _MockFinalizeProject();
    readWhitelabelConfig = _MockReadWhitelabelConfig();
    for (final step in <Future<void> Function(String)>[
      renameDartPackage.call,
      renamePlatformPackage.call,
      showAppNameChangeGuide.call,
      showLauncherIconChangeGuide.call,
      showSplashIconChangeGuide.call,
      finalizeProject.call,
    ]) {
      when(() => step(any())).thenAnswer((_) async {});
    }
    when(() => cleanProjectArtifacts(any())).thenAnswer((_) async => []);
    when(() => runFirebaseSetup(any(), any())).thenAnswer((_) async {});
    useFlavors([]);
  });

  Future<String> runMenu(List<String?> inputs) async {
    final prompter = FakePrompter(inputs);
    await RunWhitelabelSetup(
      cleanProjectArtifacts: cleanProjectArtifacts,
      renameDartPackage: renameDartPackage,
      renamePlatformPackage: renamePlatformPackage,
      showAppNameChangeGuide: showAppNameChangeGuide,
      showLauncherIconChangeGuide: showLauncherIconChangeGuide,
      showSplashIconChangeGuide: showSplashIconChangeGuide,
      runFirebaseSetup: runFirebaseSetup,
      finalizeProject: finalizeProject,
      readWhitelabelConfig: readWhitelabelConfig,
      prompter: prompter,
    )(_project);
    return prompter.output;
  }

  test('callShouldRunEachChosenStepAndExitOnNine', () async {
    final output = await runMenu(['2', '3', '4', '5', '6', '8', '9']);

    verify(() => renameDartPackage(_project)).called(1);
    verify(() => renamePlatformPackage(_project)).called(1);
    verify(() => showAppNameChangeGuide(_project)).called(1);
    verify(() => showLauncherIconChangeGuide(_project)).called(1);
    verify(() => showSplashIconChangeGuide(_project)).called(1);
    verify(() => finalizeProject(_project)).called(1);
    expect('[White-label setup: $_project]'.allMatches(output).length, 7);
  });

  test('callShouldExitIfInputHasEnded', () async {
    final output = await runMenu([]);

    expect('Select a step [1-9]: '.allMatches(output).length, 1);
  });

  test('callShouldReportAnInvalidChoiceAndAskAgain', () async {
    expect(await runMenu(['x', '9']), contains('Invalid choice.\n'));
  });

  test('callShouldReportAConfigErrorAndAskAgain', () async {
    when(() => renameDartPackage(any()))
        .thenThrow(const WhitelabelConfigException('bad config'));

    expect(await runMenu(['2', '9']), contains('Error: bad config\n'));
  });

  test('callShouldListTheRemovedArtifactsIfCleanupRemovesAny', () async {
    when(() => cleanProjectArtifacts(any()))
        .thenAnswer((_) async => ['build', 'ios/Pods']);

    expect(
      await runMenu(['1', '9']),
      contains('Removed 2 configured artifact(s):\n- build\n- ios/Pods\n'),
    );
  });

  test('callShouldSaySoIfCleanupFindsNothing', () async {
    expect(
      await runMenu(['1', '9']),
      contains('No configured artifacts found.\n'),
    );
  });

  test('callShouldSetUpFirebaseForDefaultIfThereAreNoFlavors', () async {
    await runMenu(['7', '9']);

    verify(() => runFirebaseSetup(_project, 'default')).called(1);
  });

  test('callShouldSetUpFirebaseForTheChosenFlavor', () async {
    useFlavors(['dev', 'prod']);

    final output = await runMenu(['7', 'prod', '9']);

    expect(output, contains('Enter flavor (dev/prod): '));
    verify(() => runFirebaseSetup(_project, 'prod')).called(1);
  });

  test('callShouldReportAnInvalidFlavorWithoutSettingUpFirebase', () async {
    useFlavors(['dev']);

    final output = await runMenu(['7', 'stage', '9']);

    expect(output, contains('Invalid flavor.\n'));
    verifyNever(() => runFirebaseSetup(any(), any()));
  });

  test('callShouldReportAFirebaseErrorAndAskAgain', () async {
    when(() => runFirebaseSetup(any(), any()))
        .thenThrow(const FirebaseSetupException('no login'));

    expect(await runMenu(['7', '9']), contains('Error: no login\n'));
  });

  test('callShouldUseItsOwnStepsIfNoneAreGiven', () async {
    final prompter = FakePrompter(['9']);

    await RunWhitelabelSetup(prompter: prompter)(_project);

    expect(prompter.output, contains('[White-label setup: $_project]'));
  });
}
