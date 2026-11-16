import 'package:dev_tools/src/models/whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/show_app_name_change_guide.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockReadWhitelabelConfig extends Mock implements ReadWhitelabelConfig {}

void main() {
  Future<FakePrompter> showGuide(List<String> flavors) async {
    final readWhitelabelConfig = _MockReadWhitelabelConfig();
    when(() => readWhitelabelConfig(any())).thenAnswer(
      (_) async => WhitelabelConfig(
        exclude: const [],
        flavors: flavors,
        firebase: const {},
        firebaseOutputPaths: null,
      ),
    );
    final prompter = FakePrompter(['']);
    await ShowAppNameChangeGuide(
      prompter: prompter,
      readWhitelabelConfig: readWhitelabelConfig,
    )('/project');
    return prompter;
  }

  test('callShouldListEachFlavorsStringsFileAndTheDefaultOne', () async {
    final output = (await showGuide(['dev', 'prod'])).output;

    expect(
      output,
      contains('/project/android/app/src/dev/res/values/strings.xml (for the '
          "'dev' flavor)"),
    );
    expect(output, contains('src/prod/res/values/strings.xml'));
    expect(output, contains('src/main/res/values/strings.xml (default'));
  });

  test('callShouldListOnlyTheDefaultStringsFileIfThereAreNoFlavors', () async {
    final output = (await showGuide([])).output;

    expect(output, isNot(contains('flavor)')));
    expect(output, contains('src/main/res/values/strings.xml (default'));
  });

  test('callShouldWaitForEnterBeforeFinishing', () async {
    final prompter = await showGuide([]);

    expect(prompter.readLine(), isNull);
    expect(
      prompter.output,
      endsWith("Press 'Enter' to continue... "
          '✅ App name change guide completed.\n'),
    );
  });
}
