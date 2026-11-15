import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:dev_tools/src/use_cases/whitelabel/finalize_project.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_final_todos.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockCleanProjectArtifacts extends Mock
    implements CleanProjectArtifacts {}

class _MockFindFlutterCommand extends Mock
    implements FindFvmAwareFlutterCommand {}

class _MockShowFinalTodos extends Mock implements ShowFinalTodos {}

void main() {
  late _MockCleanProjectArtifacts cleanProjectArtifacts;
  late _MockFindFlutterCommand findFlutterCommand;
  late _MockShowFinalTodos showFinalTodos;

  setUp(() {
    cleanProjectArtifacts = _MockCleanProjectArtifacts();
    findFlutterCommand = _MockFindFlutterCommand();
    showFinalTodos = _MockShowFinalTodos();
    when(() => cleanProjectArtifacts(any())).thenAnswer((_) async => []);
    when(() => findFlutterCommand()).thenAnswer((_) async => 'fvm flutter');
  });

  Future<String> finalize(FakeRunInteractiveProcess process) async {
    final prompter = FakePrompter();
    await FinalizeProject(
      prompter: prompter,
      cleanProjectArtifacts: cleanProjectArtifacts,
      findFlutterCommand: findFlutterCommand,
      showFinalTodos: showFinalTodos,
      runInteractiveProcess: process,
    )('/project');
    return prompter.output;
  }

  test('callShouldCleanRunPubGetAndShowTheTodos', () async {
    final process = FakeRunInteractiveProcess();

    final output = await finalize(process);

    verify(() => cleanProjectArtifacts('/project')).called(1);
    final call = process.calls.single;
    expect(call.executable, 'fvm');
    expect(call.arguments, ['flutter', 'pub', 'get']);
    expect(call.workingDirectory, '/project');
    verify(() => showFinalTodos('/project')).called(1);
    expect(output, isNot(contains('pub get failed')));
  });

  test('callShouldWarnAndStillShowTheTodosIfPubGetFails', () async {
    final output = await finalize(FakeRunInteractiveProcess(exitCode: 1));

    expect(output, contains('pub get failed (exit code 1)'));
    verify(() => showFinalTodos('/project')).called(1);
  });
}
