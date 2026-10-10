import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:dev_tools/src/utils/prompter.dart';
import 'package:path/path.dart' as p;

/// One backed-up `ASSETCATALOG_COMPILER_...` line from the Xcode project
/// file, kept so it can be restored if `flutter_launcher_icons` corrupts it.
class _BackedUpLine {
  final int lineNumber;
  final String originalValue;

  const _BackedUpLine(this.lineNumber, this.originalValue);
}

/// Prints launcher icon change instructions, then optionally runs
/// `flutter_launcher_icons` and fixes a known bug where it corrupts an
/// unrelated Xcode build setting.
///
/// The config file naming (`flutter_launcher_icons-<flavor>.yaml`, or
/// `flutter_launcher_icons.yaml` with no flavors) is fixed by the
/// `flutter_launcher_icons` package itself, not configurable here.
class ShowLauncherIconChangeGuide {
  static const String _pbxprojRelativePath =
      'ios/Runner.xcodeproj/project.pbxproj';
  static const String _key =
      'ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS';
  static const String _defaultConfigFile = 'flutter_launcher_icons.yaml';

  final Prompter _prompter;
  final ConfirmYesNo _confirmYesNo;
  final FindFvmAwareDartCommand _findDartCommand;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  const ShowLauncherIconChangeGuide({
    Prompter prompter = const ConsolePrompter(),
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    FindFvmAwareDartCommand findDartCommand = const FindFvmAwareDartCommand(),
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _prompter = prompter,
        _confirmYesNo = confirmYesNo,
        _findDartCommand = findDartCommand,
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Prints launcher icon config file instructions for [projectPath] — one
  /// file per flavor read via [ReadWhitelabelConfig], or the single default
  /// file when there are none — then, if confirmed, runs
  /// `flutter_launcher_icons` and restores any `$_key` entry it corrupts in
  /// the Xcode project file.
  ///
  /// Returns: nothing (void). A mismatched project file is reported and left
  /// for manual review rather than thrown, matching this being an optional,
  /// best-effort fix-up on top of a third-party tool.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when neither fvm nor a system-wide Dart is
  ///   installed (see [FindFvmAwareDartCommand]).
  /// - `WhitelabelConfigException` when `flavors` isn't configured for this
  ///   project (see [ReadWhitelabelConfig]).
  Future<void> call(String projectPath) async {
    final flavors = (await _readWhitelabelConfig(projectPath)).flavors;
    _prompter.write(_guideText(projectPath, flavors));

    if (!await _confirmYesNo('Generate launcher icons?')) {
      _prompter.write('✅ Launcher icon change guide\n');
      return;
    }

    final pbxprojFile = File(p.join(projectPath, _pbxprojRelativePath));
    final backedUpLines = _readBackedUpLines(pbxprojFile);

    final dartCommand = (await _findDartCommand()).split(RegExp(r'\s+'));
    await InteractiveProcessRunner(
      executable: dartCommand.first,
      arguments: [...dartCommand.skip(1), 'run', 'flutter_launcher_icons'],
      workingDirectory: projectPath,
    ).run();

    if (backedUpLines.isEmpty) {
      _prompter.write('✅ Launcher icon change guide\n');
      return;
    }

    _prompter.write('\n🔧 Performing known bug fixes...\n');
    final fixed = _restoreCorruptedLines(pbxprojFile, backedUpLines);
    if (fixed != null && fixed > 0) {
      _prompter.write('✅ Restored $fixed corrupted entries for $_key.\n');
    }
    _prompter.write('✅ Launcher icon change guide\n');
  }

  String _guideText(String projectPath, List<String> flavors) {
    final configFileLines = flavors.isEmpty
        ? '     - $projectPath/$_defaultConfigFile'
        : flavors
            .map(
              (flavor) => '     - $projectPath/flutter_launcher_icons-$flavor'
                  ".yaml (for the '$flavor' flavor)",
            )
            .join('\n');

    return '\n'
        '▶️ Launcher icon change guide\n'
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
        'https://pub.dev/packages/flutter_launcher_icons.\n'
        '     Follow the detailed documentation on the config files to '
        'provide proper images and other configs.\n'
        '     Also, you do not have to run any commands separately, even if '
        'the doc mentions to run any.\n'
        '🎯 • Before continuing, make sure:\n'
        '     - The image paths are valid and points to the desired images.\n'
        '     - The images follow the strict requirements described inside '
        'the config files.\n'
        '\n';
  }

  List<_BackedUpLine> _readBackedUpLines(File pbxprojFile) {
    if (!pbxprojFile.existsSync()) return const [];

    final entries = <_BackedUpLine>[];
    final lines = pbxprojFile.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final keyIndex = lines[i].indexOf(_key);
      if (keyIndex == -1) continue;
      final equalsIndex = lines[i].indexOf('= ', keyIndex);
      if (equalsIndex == -1) continue;

      var value = lines[i].substring(equalsIndex + 2);
      if (value.endsWith(';')) value = value.substring(0, value.length - 1);
      entries.add(_BackedUpLine(i + 1, value));
    }
    return entries;
  }

  int? _restoreCorruptedLines(
    File pbxprojFile,
    List<_BackedUpLine> backedUpLines,
  ) {
    final lines = pbxprojFile.readAsLinesSync();
    final corrupted = RegExp('${RegExp.escape(_key)}\\s*=\\s*AppIcon-[^;]*;');
    var fixed = 0;

    for (final backedUpLine in backedUpLines) {
      final index = backedUpLine.lineNumber - 1;
      if (index < 0 || index >= lines.length || !lines[index].contains(_key)) {
        _prompter.write(
          ' ❌ Line ${backedUpLine.lineNumber} in ${pbxprojFile.path} does '
          'not match expected state.\n'
          '    The file structure may have changed. Please revert it '
          'manually.\n',
        );
        return null;
      }

      if (corrupted.hasMatch(lines[index])) {
        lines[index] = lines[index].replaceFirst(
          corrupted,
          '$_key = ${backedUpLine.originalValue};',
        );
        fixed++;
      }
    }

    if (fixed > 0) {
      pbxprojFile.writeAsStringSync('${lines.join('\n')}\n');
    }
    return fixed;
  }
}
