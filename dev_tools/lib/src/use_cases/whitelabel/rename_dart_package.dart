import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/get_current_dart_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Replaces the Dart/Flutter package name across a copied project's files.
class RenameDartPackage {
  final Prompter _prompter;
  final GetCurrentDartPackage _getCurrentDartPackage;
  final PromptWithDefault _promptWithDefault;
  final ReplaceTextInScope _replaceTextInScope;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  RenameDartPackage({
    Prompter prompter = const ConsolePrompter(),
    GetCurrentDartPackage getCurrentDartPackage = const GetCurrentDartPackage(),
    PromptWithDefault? promptWithDefault,
    ReplaceTextInScope? replaceTextInScope,
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _prompter = prompter,
        _getCurrentDartPackage = getCurrentDartPackage,
        _promptWithDefault =
            promptWithDefault ?? PromptWithDefault(prompter: prompter),
        _replaceTextInScope = replaceTextInScope ?? ReplaceTextInScope(),
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Prompts for a source (defaulting to the package's current pubspec
  /// `name`) and target package name, then replaces every literal
  /// occurrence of the source across [projectPath] via [ReplaceTextInScope].
  ///
  /// Returns: nothing (void). An empty source or target name is reported
  /// and skips the replacement, matching the `.git` and configured
  /// white-label exclusions (see [ReadWhitelabelConfig]).
  Future<void> call(String projectPath) async {
    _prompter.write('▶️ Dart package name replacement\n');

    final currentPackage = await _getCurrentDartPackage(projectPath);
    final srcPackage = await _promptWithDefault(
      'Enter source package name',
      currentPackage,
    );
    _prompter.write('Enter target package name: ');
    final targetPackage = (_prompter.readLine() ?? '').trim();

    if (srcPackage.isEmpty || targetPackage.isEmpty) {
      _prompter.write('Error: Both package names are required, skipping.\n');
      return;
    }

    await _replaceTextInScope(
      srcText: srcPackage,
      targetText: targetPackage,
      start: projectPath,
      exclusions: [
        '.git',
        ...(await _readWhitelabelConfig(projectPath)).exclude,
      ],
    );
    _prompter.write('✅ Dart package name replacement completed.\n');
  }
}
