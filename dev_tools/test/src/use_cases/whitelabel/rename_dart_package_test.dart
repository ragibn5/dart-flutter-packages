import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:dev_tools/src/use_cases/whitelabel/get_current_dart_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/rename_dart_package.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReplaceTextInScope extends Mock implements ReplaceTextInScope {}

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

class _FixedDartPackage extends GetCurrentDartPackage {
  const _FixedDartPackage();

  @override
  Future<String> call(String projectPath) async => 'template_app';
}

void main() {
  late _MockReplaceTextInScope replaceTextInScope;
  late _MockReadWhitelabelConfig readWhitelabelConfig;

  setUp(() {
    replaceTextInScope = _MockReplaceTextInScope();
    readWhitelabelConfig = _MockReadWhitelabelConfig();
    when(
      () => replaceTextInScope(
        srcText: any(named: 'srcText'),
        targetText: any(named: 'targetText'),
        start: any(named: 'start'),
        exclusions: any(named: 'exclusions'),
      ),
    ).thenAnswer((_) async => 1);
    when(() => readWhitelabelConfig(any())).thenAnswer(
      (_) async => const WhitelabelConfig(
        exclude: ['build'],
        flavors: [],
        firebase: {},
        firebaseOutputPaths: null,
      ),
    );
  });

  RenameDartPackage sutWith(FakePrompter prompter) => RenameDartPackage(
        prompter: prompter,
        getCurrentDartPackage: const _FixedDartPackage(),
        replaceTextInScope: replaceTextInScope,
        readWhitelabelConfig: readWhitelabelConfig,
      );

  test('callShouldReplaceTheCurrentNameIfTheSourceIsLeftAtItsDefault',
      () async {
    final prompter = FakePrompter(['', 'new_app']);

    await sutWith(prompter)('/project');

    verify(
      () => replaceTextInScope(
        srcText: 'template_app',
        targetText: 'new_app',
        start: '/project',
        exclusions: ['.git', 'build'],
      ),
    ).called(1);
    expect(
        prompter.output, contains('Dart package name replacement completed'));
  });

  test('callShouldSkipTheReplacementIfTheTargetIsEmpty', () async {
    final prompter = FakePrompter(['', '']);

    await sutWith(prompter)('/project');

    verifyNever(
      () => replaceTextInScope(
        srcText: any(named: 'srcText'),
        targetText: any(named: 'targetText'),
        start: any(named: 'start'),
        exclusions: any(named: 'exclusions'),
      ),
    );
    expect(prompter.output, contains('Both package names are required'));
  });
}
