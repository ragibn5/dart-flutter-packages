import 'dart:io';

import 'imports_test.dart';
import 'package.dart';
import 'paths.dart';
import 'process.dart';

/// Runs the package's tests with every library loaded, leaving the lcov
/// report at [lcovPath].
Future<void> collectCoverage(Package package) async {
  final importsTest = writeImportsTest(package);
  try {
    await _runTestsWithCoverage(package);
  } finally {
    _deleteIfExists(importsTest);
  }
}

Future<void> _runTestsWithCoverage(Package package) =>
    package.isFlutter ? _runFlutterTests() : _runDartTests();

Future<void> _runFlutterTests() =>
    run('flutter', ['test', '--coverage', '--coverage-path', lcovPath]);

Future<void> _runDartTests() async {
  await run('dart', ['test', '--coverage=coverage']);
  await _formatDartCoverage();
}

/// Turns `dart test`'s raw coverage into lcov, honouring the
/// `coverage:ignore-*` markers.
Future<void> _formatDartCoverage() => run('dart', [
  'pub',
  'global',
  'run',
  'coverage:format_coverage',
  '--lcov',
  '--in=coverage',
  '--out=$lcovPath',
  '--report-on=lib',
  '--check-ignore',
]);

void _deleteIfExists(File? file) {
  if (file != null && file.existsSync()) file.deleteSync();
}
