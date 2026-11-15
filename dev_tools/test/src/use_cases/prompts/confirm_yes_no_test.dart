import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Future<(bool, String)> confirm(String? input) async {
    final prompter = FakePrompter([input]);
    final result = await ConfirmYesNo(prompter: prompter)('Continue?');
    return (result, prompter.output);
  }

  test('callShouldAskTheQuestionWithTheYesNoHint', () async {
    final (_, output) = await confirm('y');

    expect(output, 'Continue? [y/n]: ');
  });

  test('callShouldReturnTrueIfTheAnswerIsY', () async {
    expect((await confirm('y')).$1, isTrue);
  });

  test('callShouldReturnTrueIfTheAnswerIsYes', () async {
    expect((await confirm('yes')).$1, isTrue);
  });

  test('callShouldIgnoreCaseAndSurroundingWhitespaceIfTheAnswerIsYes',
      () async {
    expect((await confirm('  YeS ')).$1, isTrue);
  });

  test('callShouldReturnFalseIfTheAnswerIsAnythingElse', () async {
    expect((await confirm('maybe')).$1, isFalse);
  });

  test('callShouldReturnFalseIfInputHasEnded', () async {
    expect((await confirm(null)).$1, isFalse);
  });
}
