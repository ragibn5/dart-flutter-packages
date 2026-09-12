import 'package:dev_tools/src/utils/prompter.dart';

class ConfirmYesNo {
  final Prompter _prompter;

  const ConfirmYesNo({Prompter prompter = const ConsolePrompter()})
      : _prompter = prompter;

  /// Prompts [question] and reads a yes/no answer from stdin.
  ///
  /// Params:
  /// - `question`: the question to print before `[y/n]: `.
  ///
  /// Returns: true for `y`/`yes` (case-insensitive); false for anything
  /// else, including no input.
  Future<bool> call(String question) async {
    _prompter.write('$question [y/n]: ');
    final response = (_prompter.readLine() ?? '').trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }
}
