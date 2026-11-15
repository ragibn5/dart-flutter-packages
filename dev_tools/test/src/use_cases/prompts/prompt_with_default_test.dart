import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<(String, String)> prompt(String? input) async {
    final prompter = FakePrompter([input]);
    final result =
        await PromptWithDefault(prompter: prompter)('Package', 'app');
    return (result, prompter.output);
  }

  test('callShouldShowThePromptWithItsDefault', () async {
    final (_, output) = await prompt('x');

    expect(output, 'Package [app]: ');
  });

  test('callShouldReturnTheTrimmedInputIfOneIsGiven', () async {
    expect((await prompt('  my_app ')).$1, 'my_app');
  });

  test('callShouldReturnTheDefaultIfTheInputIsBlank', () async {
    expect((await prompt('   ')).$1, 'app');
  });

  test('callShouldReturnTheDefaultIfInputHasEnded', () async {
    expect((await prompt(null)).$1, 'app');
  });
}
