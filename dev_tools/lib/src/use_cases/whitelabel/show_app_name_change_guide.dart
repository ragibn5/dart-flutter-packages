import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Prints app name change instructions for one copied project and waits for
/// the user to acknowledge them.
class ShowAppNameChangeGuide {
  final Prompter _prompter;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  const ShowAppNameChangeGuide({
    Prompter prompter = const ConsolePrompter(),
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _prompter = prompter,
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Prints Android `strings.xml` (for every flavor read via
  /// [ReadWhitelabelConfig]) and iOS Xcode build-setting instructions for
  /// [projectPath], then blocks until Enter is pressed.
  ///
  /// This is guide-only: no file is read or written here. The app name must
  /// be changed manually, following the printed steps.
  Future<void> call(String projectPath) async {
    final flavors = (await _readWhitelabelConfig(projectPath)).flavors;
    final defaultStringsXmlLine =
        '     - $projectPath/android/app/src/main/res/values/strings.xml '
        '(default, used when no flavor is specified)';
    final stringsXmlLines = [
      ...flavors.map(
        (flavor) => '     - $projectPath/android/app/src/$flavor/res/values/'
            "strings.xml (for the '$flavor' flavor)",
      ),
      defaultStringsXmlLine,
    ].join('\n');

    _prompter
      ..write(
        '\n'
        '▶️ App name change guide\n'
        '⚠️ IMPORTANT: All changes below must be done in the target (copied) '
        'project, not the template.\n'
        '📁 Target project: $projectPath\n'
        '\n'
        '🤖 ANDROID:\n'
        "   • Open each flavor's strings.xml and change the 'app_name' "
        'value:\n'
        '$stringsXmlLines\n'
        '🍎 iOS:\n'
        '   1. Open $projectPath/ios/Runner.xcworkspace in Xcode.\n'
        "   2. Click 'Runner' from the project navigator (usually the first "
        'item).\n'
        "   3. Select 'Runner' from the 'TARGETS' section (usually located "
        'at right of project navigator)\n'
        "   4. Select the 'Build Settings' tab and search for "
        "'APP_DISPLAY_NAME'.\n"
        "   5. Expand the 'APP_DISPLAY_NAME' option.\n"
        '   6. Set your desired names for each flavor.\n'
        '📝 NOTE: We have not covered localized app name in this guide.\n'
        '\n'
        "Press 'Enter' to continue... ",
      )
      ..readLine()
      ..write('✅ App name change guide completed.\n');
  }
}
