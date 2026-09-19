import 'dart:io';

import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/prompts/prompt_with_default.dart';
import 'package:dev_tools/src/use_cases/whitelabel/ensure_firebase_account.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_firebase_config.dart';
import 'package:dev_tools/src/use_cases/whitelabel/read_firebase_output_paths.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_flavors.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

/// Runs `flutterfire configure` for one flavor of a white-label project.
class RunFirebaseSetup {
  static const List<String> validFlavors = whitelabelFlavors;
  static const FirebaseFlavorConfig _emptyConfig = FirebaseFlavorConfig(
    projectId: '',
    iosBundleId: '',
    androidPackageName: '',
  );

  final Logger _logger;
  final ReadFirebaseConfig _readFirebaseConfig;
  final ReadFirebaseOutputPaths _readFirebaseOutputPaths;
  final PromptWithDefault _promptWithDefault;
  final ConfirmYesNo _confirmYesNo;
  final EnsureFirebaseAccount _ensureFirebaseAccount;

  const RunFirebaseSetup({
    Logger logger = const ConsoleLogger(),
    ReadFirebaseConfig readFirebaseConfig = const ReadFirebaseConfig(),
    ReadFirebaseOutputPaths readFirebaseOutputPaths =
        const ReadFirebaseOutputPaths(),
    PromptWithDefault promptWithDefault = const PromptWithDefault(),
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    EnsureFirebaseAccount ensureFirebaseAccount = const EnsureFirebaseAccount(),
  })  : _logger = logger,
        _readFirebaseConfig = readFirebaseConfig,
        _readFirebaseOutputPaths = readFirebaseOutputPaths,
        _promptWithDefault = promptWithDefault,
        _confirmYesNo = confirmYesNo,
        _ensureFirebaseAccount = ensureFirebaseAccount;

  /// Configures Firebase for [flavor] in the project at [projectPath].
  ///
  /// First runs [EnsureFirebaseAccount] to confirm which Firebase CLI account
  /// is active, then prompts for the project ID, iOS bundle ID, and Android
  /// package name, defaulting to values read via [ReadFirebaseConfig], then
  /// runs `flutterfire configure` against the paths read via
  /// [ReadFirebaseOutputPaths] (with `{flavor}` substituted).
  ///
  /// Params:
  /// - `projectPath`: the white-label project's root directory.
  /// - `flavor`: one of [validFlavors].
  ///
  /// Returns: nothing (void). Declining the confirmation prompt aborts
  /// without error.
  ///
  /// Throws:
  /// - [FirebaseSetupException] when [flavor] is invalid, when a `firebase`
  ///   invocation fails (see [EnsureFirebaseAccount]), or when
  ///   `flutterfire configure` exits with a non-zero code.
  Future<void> call(String projectPath, String flavor) async {
    if (!validFlavors.contains(flavor)) {
      throw FirebaseSetupException(
        "Invalid flavor '$flavor'. Use one of: ${validFlavors.join(', ')}.",
      );
    }

    await _ensureFirebaseAccount();

    final defaults =
        (await _readFirebaseConfig(projectPath))[flavor] ?? _emptyConfig;
    final outputPaths =
        (await _readFirebaseOutputPaths(projectPath)).forFlavor(flavor);

    final projectId = await _promptWithDefault(
      'Enter Firebase project ID',
      defaults.projectId,
    );
    final iosBundleId = await _promptWithDefault(
      'Enter iOS bundle ID',
      defaults.iosBundleId,
    );
    final androidPackageName = await _promptWithDefault(
      'Enter Android package name',
      defaults.androidPackageName,
    );

    _logger.info(
      '\nGenerating Firebase configuration with:\n'
      'Project: $projectId\n'
      'iOS Bundle ID: $iosBundleId\n'
      'Android Package: $androidPackageName\n'
      'iOS Output: ${outputPaths.ios}\n'
      'Android Output: ${outputPaths.android}\n'
      'Dart Output: ${outputPaths.dart}',
    );

    if (!await _confirmYesNo('Continue?')) {
      _logger.info('Aborted.');
      return;
    }

    for (final relativePath in [
      outputPaths.ios,
      outputPaths.android,
      outputPaths.dart,
    ]) {
      await Directory(p.join(projectPath, p.dirname(relativePath)))
          .create(recursive: true);
    }

    _logger.info('\nRunning flutterfire configure...');
    final exitCode = await InteractiveProcessRunner(
      executable: 'flutterfire',
      arguments: [
        'configure',
        '--project=$projectId',
        '--out=${outputPaths.dart}',
        '--ios-bundle-id=$iosBundleId',
        '--ios-out=${outputPaths.ios}',
        '--android-package-name=$androidPackageName',
        '--android-out=${outputPaths.android}',
      ],
      workingDirectory: projectPath,
    ).run();

    if (exitCode != 0) {
      throw FirebaseSetupException(
        'flutterfire configure exited with code $exitCode.',
      );
    }
    _logger.info('Configuration complete for $flavor environment!');
  }
}
