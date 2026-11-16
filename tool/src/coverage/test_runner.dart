import 'dart:io';

import 'package:path/path.dart' as p;

import 'imports_test.dart';
import 'package.dart';
import 'paths.dart';
import 'process.dart';

/// Runs the package's tests with every library loaded, leaving the lcov
/// report at [lcovPath].
Future<void> collectCoverage(Package package) async {
  _clearPreviousResults(package);
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

/// Deletes the lcov report and `dart test`'s raw results from an earlier run,
/// which format_coverage would otherwise merge in, stale line numbers and
/// deleted tests' hits included.
void _clearPreviousResults(Package package) {
  _deleteIfExists(File(p.join(package.dir, lcovPath)));
  final rawResults = Directory(p.join(package.dir, 'coverage'));
  if (!rawResults.existsSync()) return;
  rawResults
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.vm.json'))
      .forEach(_deleteIfExists);
}

void _deleteIfExists(File? file) {
  if (file != null && file.existsSync()) file.deleteSync();
}
