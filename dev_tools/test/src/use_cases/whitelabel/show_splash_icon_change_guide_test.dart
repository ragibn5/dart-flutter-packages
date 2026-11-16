import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_splash_icon_change_guide.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

class _MockFindDartCommand extends Mock implements FindFvmAwareDartCommand {}

void main() {
  late FakeRunInteractiveProcess process;

  setUp(() => process = FakeRunInteractiveProcess());

  Future<String> showGuide(List<String> flavors, String answer) async {
    final readWhitelabelConfig = _MockReadWhitelabelConfig();
    when(() => readWhitelabelConfig(any())).thenAnswer(
      (_) async => WhitelabelConfig(
        exclude: const [],
        flavors: flavors,
        firebase: const {},
        firebaseOutputPaths: null,
      ),
    );
    final findDartCommand = _MockFindDartCommand();
    when(findDartCommand.call).thenAnswer((_) async => 'fvm dart');
    final prompter = FakePrompter([answer]);
    await ShowSplashIconChangeGuide(
      prompter: prompter,
      confirmYesNo: ConfirmYesNo(prompter: prompter),
      findDartCommand: findDartCommand,
      readWhitelabelConfig: readWhitelabelConfig,
      runInteractiveProcess: process,
    )('/project');
    return prompter.output;
  }

  test('callShouldListEachFlavorsConfigFileAndGenerateForAllFlavors', () async {
    final output = await showGuide(['dev', 'prod'], 'y');

    expect(
      output,
      contains("/project/flutter_native_splash-dev.yaml (for the 'dev' "
          'flavor)'),
    );
    expect(output, contains('flutter_native_splash-prod.yaml'));
    final call = process.calls.single;
    expect(call.executable, 'fvm');
    expect(call.arguments, [
      'dart',
      'run',
      'flutter_native_splash:create',
      '--all-flavors',
    ]);
    expect(call.workingDirectory, '/project');
    expect(output, endsWith('✅ Splash icon change guide\n'));
  });

  test('callShouldUseTheDefaultConfigFileIfThereAreNoFlavors', () async {
    final output = await showGuide([], 'y');

    expect(output, contains('     - /project/flutter_native_splash.yaml\n'));
    expect(process.calls.single.arguments, [
      'dart',
      'run',
      'flutter_native_splash:create',
    ]);
  });

  test('callShouldSkipGeneratingIfNotConfirmed', () async {
    final output = await showGuide([], 'n');

    expect(process.calls, isEmpty);
    expect(output, endsWith('✅ Splash icon change guide\n'));
  });
}
