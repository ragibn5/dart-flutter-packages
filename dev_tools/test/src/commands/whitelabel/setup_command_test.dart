import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/setup_command.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/copy_template_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_whitelabel_setup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockCopyTemplateProject extends Mock implements CopyTemplateProject {}

class _MockRunWhitelabelSetup extends Mock implements RunWhitelabelSetup {}

void main() {
  late Directory tempDir;
  late _MockCopyTemplateProject copyTemplateProject;
  late _MockRunWhitelabelSetup runWhitelabelSetup;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('setup_command');
    copyTemplateProject = _MockCopyTemplateProject();
    runWhitelabelSetup = _MockRunWhitelabelSetup();
    when(
      () => copyTemplateProject(
        template: any(named: 'template'),
        destination: any(named: 'destination'),
        allowExistingEmptyDirectory: any(named: 'allowExistingEmptyDirectory'),
      ),
    ).thenAnswer((_) async => '/abs/copied');
    when(() => runWhitelabelSetup(any())).thenAnswer((_) async {});
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  CommandRunner<void> runnerAnswering(String? answer) =>
      CommandRunner<void>('dev_tools', 'test')
        ..addCommand(
          SetupCommand(
            copyTemplateProject: copyTemplateProject,
            runWhitelabelSetup: runWhitelabelSetup,
            confirmYesNo: ConfirmYesNo(prompter: FakePrompter([answer])),
          ),
        );

  String existingProject() {
    final path = '${tempDir.path}/existing';
    File('$path/pubspec.yaml')
      ..createSync(recursive: true)
      ..writeAsStringSync('name: existing\n');
    return path;
  }

  test('runShouldCopyTheTemplateAndSetUpTheCopyIfThePathIsNew', () async {
    final path = '${tempDir.path}/new_app';

    await runnerAnswering(null).run(['setup', '-t', '/template', path]);

    verify(
      () => copyTemplateProject(
        template: '/template',
        destination: path,
        allowExistingEmptyDirectory: true,
      ),
    ).called(1);
    verify(() => runWhitelabelSetup('/abs/copied')).called(1);
  });

  test('runShouldSetUpAnExistingProjectInPlaceIfConfirmed', () async {
    final path = existingProject();

    final printed = await capturePrints(
      () => runnerAnswering('y').run(['setup', path]),
    );

    expect(printed, contains("'$path' already exists"));
    verifyNever(
      () => copyTemplateProject(
        template: any(named: 'template'),
        destination: any(named: 'destination'),
        allowExistingEmptyDirectory: any(named: 'allowExistingEmptyDirectory'),
      ),
    );
    verify(() => runWhitelabelSetup(Directory(path).absolute.path)).called(1);
  });

  test('runShouldAbortIfSettingUpAnExistingProjectIsNotConfirmed', () async {
    final printed = await capturePrints(
      () => runnerAnswering('n').run(['setup', existingProject()]),
    );

    expect(printed, endsWith('Aborted.\n'));
    verifyNever(() => runWhitelabelSetup(any()));
  });

  test('runShouldRejectAnythingButOnePath', () {
    expect(
      runnerAnswering(null).run(['setup']),
      throwsA(isA<UsageException>()),
    );
  });

  test('descriptionShouldDescribeTheCommand', () {
    expect(SetupCommand().description, SetupCommand.commandDescription);
  });
}
