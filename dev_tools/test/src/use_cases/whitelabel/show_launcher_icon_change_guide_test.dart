import 'dart:io';

import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_launcher_icon_change_guide.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

class _MockFindDartCommand extends Mock implements FindFvmAwareDartCommand {}

const _key = 'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS';

void main() {
  late Directory project;
  late File pbxproj;

  setUp(() {
    project = Directory.systemTemp.createTempSync('launcher_icon_guide');
    pbxproj = File('${project.path}/ios/Runner.xcodeproj/project.pbxproj');
  });

  tearDown(() => project.deleteSync(recursive: true));

  void writePbxproj(List<String> lines) =>
      (pbxproj..createSync(recursive: true))
          .writeAsStringSync('${lines.join('\n')}\n');

  Future<(String, FakeRunInteractiveProcess)> showGuide({
    List<String> flavors = const [],
    String answer = 'y',
    void Function()? tool,
  }) async {
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
    final process = FakeRunInteractiveProcess(onRun: (_) => tool?.call());
    final prompter = FakePrompter([answer]);
    await ShowLauncherIconChangeGuide(
      prompter: prompter,
      confirmYesNo: ConfirmYesNo(prompter: prompter),
      findDartCommand: findDartCommand,
      readWhitelabelConfig: readWhitelabelConfig,
      runInteractiveProcess: process,
    )(project.path);
    return (prompter.output, process);
  }

  test('callShouldListEachFlavorsConfigFileAndRunTheTool', () async {
    final (output, process) = await showGuide(flavors: ['dev', 'prod']);

    expect(
      output,
      contains("flutter_launcher_icons-dev.yaml (for the 'dev' flavor)"),
    );
    expect(output, contains('flutter_launcher_icons-prod.yaml'));
    final call = process.calls.single;
    expect(call.executable, 'fvm');
    expect(call.arguments, ['dart', 'run', 'flutter_launcher_icons']);
    expect(call.workingDirectory, project.path);
    expect(output, endsWith('✅ Launcher icon change guide\n'));
  });

  test('callShouldUseTheDefaultConfigFileIfThereAreNoFlavors', () async {
    final (output, _) = await showGuide();

    expect(
      output,
      contains('     - ${project.path}/flutter_launcher_icons.yaml\n'),
    );
  });

  test('callShouldSkipTheToolIfNotConfirmed', () async {
    final (output, process) = await showGuide(answer: 'n');

    expect(process.calls, isEmpty);
    expect(output, endsWith('✅ Launcher icon change guide\n'));
  });

  test('callShouldRestoreTheSettingsTheToolCorrupts', () async {
    writePbxproj([
      '/* $_key has no value here */',
      '  $_key = YES;',
      '  $_key = NO',
    ]);

    final (output, _) = await showGuide(
      tool: () => writePbxproj([
        '/* $_key has no value here */',
        '  $_key = AppIcon-dev;',
        '  $_key = AppIcon-dev;',
      ]),
    );

    expect(pbxproj.readAsLinesSync(), [
      '/* $_key has no value here */',
      '  $_key = YES;',
      '  $_key = NO;',
    ]);
    expect(output, contains('✅ Restored 2 corrupted entries for $_key.'));
  });

  test('callShouldLeaveTheFileIfTheToolLeftTheSettingsIntact', () async {
    writePbxproj(['  $_key = YES;']);

    final (output, _) = await showGuide(tool: () {});

    expect(pbxproj.readAsLinesSync(), ['  $_key = YES;']);
    expect(output, contains('Performing known bug fixes'));
    expect(output, isNot(contains('Restored')));
  });

  test('callShouldReportAndLeaveTheFileIfItsLinesMoved', () async {
    writePbxproj(['  $_key = YES;']);

    final (output, _) = await showGuide(
      tool: () => writePbxproj(['  something else = AppIcon-dev;']),
    );

    expect(pbxproj.readAsLinesSync(), ['  something else = AppIcon-dev;']);
    expect(output, contains('Line 1 in ${pbxproj.path} does not match'));
    expect(output, isNot(contains('Restored')));
  });
}
