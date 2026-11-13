import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:path/path.dart' as p;

/// Runs a single package's tests with coverage enabled, using whichever
/// Dart/Flutter is on `PATH` — not each package's own fvm-pinned version,
/// since running tests (unlike publishing) doesn't need to match pub.dev's
/// exact resolved SDK.
class RunPackageTestsWithCoverage {
  /// The test written for the run, which imports every library in `lib/`.
  static const importsTestPath = 'test/dev_tools_coverage_imports_test.dart';

  final String _flutterExecutable;
  final String _dartExecutable;
  final String _lcovExecutable;
  final ReadCoverageConfig _readCoverageConfig;

  const RunPackageTestsWithCoverage({
    String flutterExecutable = 'flutter',
    String dartExecutable = 'dart',
    String lcovExecutable = 'lcov',
    ReadCoverageConfig readCoverageConfig = const ReadCoverageConfig(),
  })  : _flutterExecutable = flutterExecutable,
        _dartExecutable = dartExecutable,
        _lcovExecutable = lcovExecutable,
        _readCoverageConfig = readCoverageConfig;

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
  /// Notes: coverage only counts the libraries a test run loads, so a file no
  /// test imports would be missing rather than uncovered. For the run, a test
  /// at [importsTestPath] imports every library in the package's `lib/`
  /// (part files aside), and is deleted afterwards.
  ///
  /// A Dart package's lcov conversion requires the `coverage`
  /// package pre-activated globally (`dart pub global activate coverage`).
  /// Afterwards, exclude patterns from the package's own
  /// `dev_tools_coverage_config.yaml` (see [ReadCoverageConfig]) are
  /// filtered out of the lcov data, if any.
  Future<void> call({
    required String packagePath,
    required bool isFlutterPackage,
    String lcovFile = 'coverage/lcov.info',
  }) async {
    final importsTest = _writeImportsTest(packagePath, isFlutterPackage);
    try {
      await _runTests(packagePath, isFlutterPackage, lcovFile);
    } finally {
      if (importsTest != null && importsTest.existsSync()) {
        importsTest.deleteSync();
      }
    }

    await _applyExclusions(packagePath, lcovFile);
  }

  Future<void> _runTests(
    String packagePath,
    bool isFlutterPackage,
    String lcovFile,
  ) async {
    if (isFlutterPackage) {
      await _run(_flutterExecutable, ['pub', 'get'], packagePath);
      // With the test assets: without them, Material widgets that need a
      // shader (such as the ink sparkle of a button) fail to render.
      await _run(
        _flutterExecutable,
        [
          'test',
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
  }

  /// Writes a test that imports every library in [packagePath]'s `lib/`, so
  /// the run loads them all; `null` when there's no `lib/` or no pubspec to
  /// name the package by.
  File? _writeImportsTest(String packagePath, bool isFlutterPackage) {
    final pubspec = File(p.join(packagePath, 'pubspec.yaml'));
    final libDir = Directory(p.join(packagePath, 'lib'));
    if (!pubspec.existsSync() || !libDir.existsSync()) return null;

    final name = _packageName.firstMatch(pubspec.readAsStringSync())?[1];
    if (name == null) return null;

    final libraries = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !_partOf.hasMatch(f.readAsStringSync()))
        .map((f) =>
            p.posix.joinAll(p.split(p.relative(f.path, from: libDir.path))))
        .toList()
      ..sort();

    final testImport = isFlutterPackage
        ? 'package:flutter_test/flutter_test.dart'
        : 'package:test/test.dart';
    final file = File(p.join(packagePath, importsTestPath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync([
        '// Written by dev_tools for a coverage run, and deleted after it.',
        '// ignore_for_file: unused_import, directives_ordering',
        "import '$testImport';",
        for (final (i, library) in libraries.indexed)
          "import 'package:$name/$library' as _i$i;",
        '',
        "void main() => test('loads every library', () {});",
        '',
      ].join('\n'));
    return file;
  }

  static final _packageName = RegExp(r'^name:\s*(\S+)', multiLine: true);

  static final _partOf = RegExp(r'^\s*part\s+of\b', multiLine: true);

  Future<void> _applyExclusions(String packagePath, String lcovFile) async {
    final config = await _readCoverageConfig(packagePath);
    if (config.exclude.isEmpty) return;

    await _run(
      _lcovExecutable,
      [
        '--remove',
        lcovFile,
        ...config.exclude,
        '--output-file',
        lcovFile,
        // A pattern that matches nothing (common — exclusions are written
        // once for the whole package, not for what a given diff touched)
        // is a hard error on newer lcov versions otherwise.
        '--ignore-errors',
        'unused,empty',
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
        '`$executable ${arguments.join(' ')}` exited with code $exitCode '
        'in $workingDirectory.',
      );
    }
  }
}

class PackageTestException extends CommandExecutionException {
  @override
  final String message;

  const PackageTestException(this.message);
}
