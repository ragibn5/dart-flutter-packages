import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';

/// Runs a single package's tests with coverage enabled, using whichever
/// Dart/Flutter is on `PATH` — not each package's own fvm-pinned version,
/// since running tests (unlike publishing) doesn't need to match pub.dev's
/// exact resolved SDK.
class RunPackageTestsWithCoverage {
  final String _flutterExecutable;
  final String _dartExecutable;

  const RunPackageTestsWithCoverage({
    String flutterExecutable = 'flutter',
    String dartExecutable = 'dart',
  })  : _flutterExecutable = flutterExecutable,
        _dartExecutable = dartExecutable;

  /// Params:
  /// - `packagePath`: absolute path to the package to test.
  /// - `isFlutterPackage`: selects `flutter test` vs `dart test`.
  /// - `lcovFile`: output path of the lcov file, relative to [packagePath]
  ///   (default 'coverage/lcov.info').
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PackageTestException] when `pub get`, the test run, or (for a Dart
  ///   package) the lcov conversion exits non-zero.
  ///
  /// Notes: a Dart package's lcov conversion requires the `coverage`
  /// package pre-activated globally (`dart pub global activate coverage`).
  Future<void> call({
    required String packagePath,
    required bool isFlutterPackage,
    String lcovFile = 'coverage/lcov.info',
  }) async {
    if (isFlutterPackage) {
      await _run(_flutterExecutable, ['pub', 'get'], packagePath);
      await _run(
        _flutterExecutable,
        [
          'test',
          '--no-test-assets',
          '--coverage',
          '--coverage-path',
          lcovFile,
        ],
        packagePath,
      );
      return;
    }

    await _run(_dartExecutable, ['pub', 'get'], packagePath);
    await _run(_dartExecutable, ['test', '--coverage=coverage'], packagePath);
    await _run(
      _dartExecutable,
      [
        'pub',
        'global',
        'run',
        'coverage:format_coverage',
        '--lcov',
        '--in=coverage',
        '--out=$lcovFile',
        '--report-on=lib',
        '--check-ignore',
      ],
      packagePath,
    );
  }

  Future<void> _run(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) async {
    final runner = InteractiveProcessRunner(
      executable: executable,
      arguments: arguments,
      workingDirectory: workingDirectory,
    );
    final exitCode = await runner.run();
    if (exitCode != 0) {
      throw PackageTestException(
        'Error($exitCode): `$executable ${arguments.join(' ')}` failed in '
        '$workingDirectory.',
      );
    }
  }
}

class PackageTestException extends CommandExecutionException {
  @override
  final String message;

  const PackageTestException(this.message);
}
