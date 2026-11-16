import 'package:dev_tools/src/utils/prompter.dart';

class PromptWithDefault {
  final Prompter _prompter;

  const PromptWithDefault({Prompter prompter = const ConsolePrompter()})
      : _prompter = prompter;

  /// Prompts [prompt] and reads a line via this instance's [Prompter],
  /// falling back to a default.
  ///
  /// Params:
  /// - `prompt`: the prompt to print before `[defaultValue]: `.
  /// - `defaultValue`: returned when the input is empty.
  ///
  /// Returns: the trimmed input, or [defaultValue] when empty.
  Future<String> call(String prompt, String defaultValue) async {
    _prompter.write('$prompt [$defaultValue]: ');
    final input = (_prompter.readLine() ?? '').trim();
    return input.isEmpty ? defaultValue : input;
  }
}
