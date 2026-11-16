import 'package:dev_tools/src/use_cases/whitelabel/show_final_todos.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('callShouldPrintTheTodosForTheProject', () {
    final prompter = FakePrompter();

    ShowFinalTodos(prompter: prompter)('/project');

    expect(prompter.output, contains('📁 Target project: /project'));
    expect(prompter.output, contains('• /project/pubspec.yaml'));
    expect(prompter.output, contains('/project/ios/GoogleService-Info.plist'));
  });
}
