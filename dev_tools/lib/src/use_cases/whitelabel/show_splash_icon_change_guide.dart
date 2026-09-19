import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_splash_config_path.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_flavors.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:dev_tools/src/utils/prompter.dart';

/// Prints splash icon change instructions, then optionally runs
/// `flutter_native_splash:create` for every flavor.
class ShowSplashIconChangeGuide {
  final Prompter _prompter;
  final ConfirmYesNo _confirmYesNo;
  final FindFvmAwareDartCommand _findDartCommand;
  final ReadSplashConfigPath _readSplashConfigPath;

  const ShowSplashIconChangeGuide({
    Prompter prompter = const ConsolePrompter(),
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    FindFvmAwareDartCommand findDartCommand = const FindFvmAwareDartCommand(),
    ReadSplashConfigPath readSplashConfigPath = const ReadSplashConfigPath(),
  })  : _prompter = prompter,
        _confirmYesNo = confirmYesNo,
        _findDartCommand = findDartCommand,
        _readSplashConfigPath = readSplashConfigPath;

  /// Prints per-flavor splash config file instructions for [projectPath],
  /// with paths read via [ReadSplashConfigPath] (`{flavor}` substituted),
  /// then, if confirmed, runs `flutter_native_splash:create --all-flavors`.
  ///
  /// Returns: nothing (void). Declining the confirmation prompt skips the
  /// command without error.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when neither fvm nor a system-wide Dart is
  ///   installed (see [FindFvmAwareDartCommand]).
  Future<void> call(String projectPath) async {
    final configPathTemplate = await _readSplashConfigPath(projectPath);
    _prompter.write(_guideText(projectPath, configPathTemplate));

    if (!await _confirmYesNo('Generate splash icons?')) {
      _prompter.write('✅ Splash icon change guide\n');
      return;
    }

    final dartCommand = (await _findDartCommand()).split(RegExp(r'\s+'));
    await InteractiveProcessRunner(
      executable: dartCommand.first,
      arguments: [
        ...dartCommand.skip(1),
        'run',
        'flutter_native_splash:create',
        '--all-flavors',
      ],
      workingDirectory: projectPath,
    ).run();
    _prompter.write('✅ Splash icon change guide\n');
  }

  String _guideText(String projectPath, String configPathTemplate) {
    final configFileLines = whitelabelFlavors
        .map(
          (flavor) => '     - $projectPath/'
              "${configPathTemplate.replaceAll('{flavor}', flavor)} "
              "(for the '$flavor' flavor)",
        )
        .join('\n');

    return '\n'
        '▶️ Splash icon change guide\n'
        '⚠️ IMPORTANT: All changes below must be done in the target (copied) '
        'project, not the template.\n'
        '📁 Target project: $projectPath\n'
        '\n'
        "📁 • Open each flavor's config file:\n"
        '$configFileLines\n'
        '🛠️ • Customize settings in each file, such as:\n'
        '     - Update image paths\n'
        '     - Set background colors\n'
        '     - Enable or disable specific options\n'
        '     - Or anything else, see '
        'https://pub.dev/packages/flutter_native_splash.\n'
        '     Follow the detailed documentation on the config files to '
        'provide proper images and other configs.\n'
        '     Also, you do not have to run any commands separately, even if '
        'the doc mentions to run any.\n'
        '🎯 • Before continuing, make sure:\n'
        '     - The image paths are valid and points to the desired '
        'images.\n'
        '     - The images follow the strict requirements described inside '
        'the config files.\n'
        '\n';
  }
}
