import 'dart:io';

import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/get_current_platform_package.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_whitelabel_config.dart';
import 'package:dev_tools/src/utils/prompter.dart';
import 'package:path/path.dart' as p;

/// Replaces the Android/iOS platform package name (application ID / bundle
/// ID) across a copied project's files, and moves the Android Kotlin/Java
/// source directories that encode the package name in their path.
class RenamePlatformPackage {
  /// Android module languages that may have package-name-based directories.
  static const List<String> _androidPackageLanguages = ['kotlin', 'java'];

  /// Android source set directories that may contain package-name-based
  /// Kotlin/Java folders. Add/remove entries here if a flavor or source set
  /// is added/removed.
  static const List<String> _androidSourceSetDirs = [
    'main',
    'debug',
    'profile',
    'dev',
    'exp',
    'stage',
    'prod',
    'test',
    'testDev',
    'testExp',
    'testStage',
    'testProd',
    'androidTest',
    'androidTestDev',
    'androidTestExp',
    'androidTestStage',
    'androidTestProd',
  ];

  final Prompter _prompter;
  final GetCurrentPlatformPackage _getCurrentPlatformPackage;
  final PromptWithDefault _promptWithDefault;
  final ReplaceTextInScope _replaceTextInScope;
  final ReadWhitelabelConfig _readWhitelabelConfig;

  RenamePlatformPackage({
    Prompter prompter = const ConsolePrompter(),
    GetCurrentPlatformPackage getCurrentPlatformPackage =
        const GetCurrentPlatformPackage(),
    PromptWithDefault? promptWithDefault,
    ReplaceTextInScope? replaceTextInScope,
    ReadWhitelabelConfig readWhitelabelConfig = const ReadWhitelabelConfig(),
  })  : _prompter = prompter,
        _getCurrentPlatformPackage = getCurrentPlatformPackage,
        _promptWithDefault =
            promptWithDefault ?? PromptWithDefault(prompter: prompter),
        _replaceTextInScope = replaceTextInScope ?? ReplaceTextInScope(),
        _readWhitelabelConfig = readWhitelabelConfig;

  /// Prompts for a source (defaulting to the current Android
  /// `applicationId`) and target platform package name, replaces every
  /// literal occurrence across [projectPath] via [ReplaceTextInScope], then
  /// moves the Android Kotlin/Java source directories under the old package
  /// path to the new one.
  ///
  /// Returns: nothing (void). An empty source or target name is reported
  /// and skips the rename. iOS has no package-based directories to move,
  /// since it uses a flat directory structure.
  Future<void> call(String projectPath) async {
    _prompter.write('▶️ Platform package name replacement\n');

    final currentPackage = await _getCurrentPlatformPackage(projectPath);
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

    _prompter.write('Searching for package name occurrences ...\n');
    await _replaceTextInScope(
      srcText: srcPackage,
      targetText: targetPackage,
      start: projectPath,
      exclusions: [
        '.git',
        ...await _readWhitelabelConfig(projectPath),
      ],
    );

    await _moveAndroidPackageDirectories(
        projectPath, srcPackage, targetPackage);
    _prompter.write('✅ Platform package name replacement completed.\n');
  }

  Future<void> _moveAndroidPackageDirectories(
    String projectPath,
    String srcPackage,
    String targetPackage,
  ) async {
    final srcRelPath = srcPackage.replaceAll('.', '/');
    final targetRelPath = targetPackage.replaceAll('.', '/');
    final movedDirs = <String>[];

    for (final dir in _androidSourceSetDirs) {
      for (final lang in _androidPackageLanguages) {
        final srcDir = Directory(
          p.join(projectPath, 'android/app/src/$dir/$lang', srcRelPath),
        );
        if (!srcDir.existsSync()) continue;

        final targetPath = p.join(
          projectPath,
          'android/app/src/$dir/$lang',
          targetRelPath,
        );
        await Directory(p.dirname(targetPath)).create(recursive: true);
        await srcDir.rename(targetPath);
        movedDirs.add('${srcDir.path} -> $targetPath');
      }
    }

    if (movedDirs.isEmpty) return;
    _prompter.write(
      'Moving package directories...\n'
      '${movedDirs.map((entry) => 'Moved: $entry').join('\n')}\n',
    );
  }
}
