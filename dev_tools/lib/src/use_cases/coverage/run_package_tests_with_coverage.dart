import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_exclusions.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';

/// Runs a single package's tests with coverage enabled, using whichever
/// Dart/Flutter is on `PATH` — not each package's own fvm-pinned version,
/// since running tests (unlike publishing) doesn't need to match pub.dev's
/// exact resolved SDK.
class RunPackageTestsWithCoverage {
  final String _flutterExecutable;
  final String _dartExecutable;
  final String _lcovExecutable;
  final ReadCoverageExclusions _readCoverageExclusions;

  const RunPackageTestsWithCoverage({
    String flutterExecutable = 'flutter',
    String dartExecutable = 'dart',
    String lcovExecutable = 'lcov',
    ReadCoverageExclusions readCoverageExclusions =
        const ReadCoverageExclusions(),
  })  : _flutterExecutable = flutterExecutable,
        _dartExecutable = dartExecutable,
        _lcovExecutable = lcovExecutable,
        _readCoverageExclusions = readCoverageExclusions;

  /// Params:
  /// - `packagePath`: absolute path to the package to test.
  /// - `isFlutterPackage`: selects `flutter test` vs `dart test`.
  /// - `lcovFile`: output path of the lcov file, relative to [packagePath]
  ///   (default 'coverage/lcov.info').
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PackageTestException] when `pub get`, the test run, (for a Dart
  ///   package) the lcov conversion, or the exclusions filtering step
  ///   exits non-zero.
  ///
  /// Notes: a Dart package's lcov conversion requires the `coverage`
  /// package pre-activated globally (`dart pub global activate coverage`).
  /// Afterwards, patterns from the package's own `.coverage_exclude` (see
  /// [ReadCoverageExclusions]) are filtered out of the lcov data, if any.
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
    } else {
      await _run(_dartExecutable, ['pub', 'get'], packagePath);
      await _run(
        _dartExecutable,
        ['test', '--coverage=coverage'],
        packagePath,
      );
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

    await _applyExclusions(packagePath, lcovFile);
  }

  Future<void> _applyExclusions(String packagePath, String lcovFile) async {
    final exclusions = await _readCoverageExclusions(packagePath);
    if (exclusions.isEmpty) return;

    await _run(
      _lcovExecutable,
      [
        '--remove',
        lcovFile,
        ...exclusions,
        '--output-file',
        lcovFile,
        // A pattern that matches nothing (common — exclusions are written
        // once for the whole package, not for what a given diff touched)
        // is a hard error on newer lcov versions otherwise.
        '--ignore-errors',
        'unused',
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
