import 'package:dev_tools/src/utils/prompter.dart';

/// Prints the remaining manual TODOs for one finished white-label project.
class ShowFinalTodos {
  final Prompter _prompter;

  const ShowFinalTodos({Prompter prompter = const ConsolePrompter()})
      : _prompter = prompter;

  /// Prints the completion message and manual follow-up steps for
  /// [projectPath]. This is guide-only: no file is read or written here.
  void call(String projectPath) {
    _prompter.write(
      '\n'
      '🎯 Congratulations! You’ve successfully set up the project.\n'
      '⚠️ IMPORTANT: All changes below must be done in the target (copied) '
      'project, not the template.\n'
      '📁 Target project: $projectPath\n'
      '\n'
      '🔄 Next steps:\n'
      "• Restart your IDE — it's recommended to clean the IDE cache "
      'beforehand.\n'
      '\n'
      '🧹 Optional cleanup:\n'
      '• You can safely delete this script file afterwards.\n'
      '\n'
      '🛠️ Update these files to reflect your project:\n'
      '• $projectPath/README.md\n'
      '• $projectPath/pubspec.yaml (update these fields):\n'
      '  - name\n'
      '  - description\n'
      '  - repository\n'
      '  - issue_tracker\n'
      '  - homepage\n'
      '  - And anything else that reflects a template project property.\n'
      '\n'
      '⚠️ Remove or replace the dev_tools dev_dependency in pubspec.yaml — '
      "it points at the original template's monorepo-relative "
      "../dev_tools path, which won't exist here. pub get will fail until "
      'this is fixed.\n'
      '\n'
      '⚠️ No matter what you do, XCode will have some issues:\n'
      '- Make sure $projectPath/ios/GoogleService-Info.plist exists.\n'
      '- If not, copy '
      '$projectPath/ios/Config/Firebase/dev/GoogleService-Info.plist to '
      '$projectPath/ios/.\n'
      '- If there are any issue related to pod and Podfile, delete '
      '$projectPath/ios/Podfile.lock and then run "pod install" or "pod '
      'repo update".\n'
      '\n'
      '🎯 Verify the project setup by running it into all platforms.\n'
      '\n'
      '📚 If anything seems off, refer to the README.md in the original '
      'template project.\n',
    );
  }
}
