// Checks one package's line coverage against its threshold.
//
// Usage, from the package's folder (Melos runs it in each one):
//   dart run <repo>/tool/coverage.dart [--threshold <percent>]
//
// - Every library in lib/ counts, not only those a test imports: a test
//   importing them all is written for the run and deleted afterwards.
// - Excluded files: the patterns under `exclude:` in the repository root's
//   coverage.yaml, then the package's own coverage.yaml.
// - The package's coverage.yaml `threshold:` overrides --threshold
//   (default 100). A package with nothing left to measure passes.
//
// Requires lcov, and for a pure-Dart package the coverage package activated
// globally (`dart pub global activate coverage`).

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _configFileName = 'coverage.yaml';
const _importsTestPath = 'test/coverage_imports_test.dart';
const _lcovPath = 'coverage/lcov.info';
const _defaultThreshold = 100.0;

Future<void> main(List<String> args) async {
  final package = _Package.current();
  final packageConfig = _readConfig(p.join(package.dir, _configFileName));
  final repoConfig = _readConfig(p.join(_repoRoot(), _configFileName));

  await _collectCoverage(package);
  await _removeExcluded(_combinedExclude(repoConfig, packageConfig));

  final passed = _report(
    package.name,
    _lineCounts(File(p.join(package.dir, _lcovPath))),
    _requiredThreshold(packageConfig, args),
  );
  if (!passed) exit(1);
}

// Package and repository.

/// The repository root: the folder above this script's tool/.
String _repoRoot() => p.dirname(p.dirname(Platform.script.toFilePath()));

YamlMap _readPubspec(String packageDir) =>
    loadYaml(File(p.join(packageDir, 'pubspec.yaml')).readAsStringSync())
        as YamlMap;

String _packageName(YamlMap pubspec) => pubspec['name'] as String;

bool _dependsOnFlutter(YamlMap pubspec) =>
    (pubspec['dependencies'] as YamlMap?)?['flutter'] != null;

// Settings.

_CoverageConfig _readConfig(String path) {
  final doc = _readYamlMap(path);
  if (doc == null) return const _CoverageConfig.empty();
  return _CoverageConfig(
    exclude: _readExclude(doc),
    threshold: _readThreshold(doc),
  );
}

/// The YAML map in the file at [path]; `null` when it's missing or holds no
/// map.
YamlMap? _readYamlMap(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  final doc = loadYaml(file.readAsStringSync());
  return doc is YamlMap ? doc : null;
}

List<String> _readExclude(YamlMap config) {
  final exclude = config['exclude'];
  return exclude is YamlList ? exclude.map((e) => '$e').toList() : const [];
}

double? _readThreshold(YamlMap config) {
  final threshold = config['threshold'];
  return threshold is num ? threshold.toDouble() : null;
}

/// The package's threshold, else the --threshold argument, else the default.
double _requiredThreshold(_CoverageConfig packageConfig, List<String> args) =>
    packageConfig.threshold ?? _thresholdArg(args) ?? _defaultThreshold;

double? _thresholdArg(List<String> args) {
  final i = args.indexOf('--threshold');
  return i >= 0 && i + 1 < args.length ? double.tryParse(args[i + 1]) : null;
}

/// The repository's exclusions, then the package's.
List<String> _combinedExclude(
  _CoverageConfig repoConfig,
  _CoverageConfig packageConfig,
) => [...repoConfig.exclude, ...packageConfig.exclude];

// Collecting coverage.

/// Runs the package's tests with every library loaded, leaving the lcov
/// report at [_lcovPath].
Future<void> _collectCoverage(_Package package) async {
  final importsTest = _writeImportsTest(package);
  try {
    await _runTestsWithCoverage(package);
  } finally {
    _deleteIfExists(importsTest);
  }
}

Future<void> _runTestsWithCoverage(_Package package) =>
    package.isFlutter ? _runFlutterTests() : _runDartTests();

Future<void> _runFlutterTests() =>
    _run('flutter', ['test', '--coverage', '--coverage-path', _lcovPath]);

Future<void> _runDartTests() async {
  await _run('dart', ['test', '--coverage=coverage']);
  await _formatDartCoverage();
}

/// Turns `dart test`'s raw coverage into lcov, honouring the
/// `coverage:ignore-*` markers.
Future<void> _formatDartCoverage() => _run('dart', [
  'pub',
  'global',
  'run',
  'coverage:format_coverage',
  '--lcov',
  '--in=coverage',
  '--out=$_lcovPath',
  '--report-on=lib',
  '--check-ignore',
]);

void _deleteIfExists(File? file) {
  if (file != null && file.existsSync()) file.deleteSync();
}

// The imports test.

/// Writes a test that imports every library in lib/ (part files aside), so
/// the run loads them all; `null` when there's no lib/.
File? _writeImportsTest(_Package package) {
  final libDir = Directory(p.join(package.dir, 'lib'));
  if (!libDir.existsSync()) return null;
  return File(p.join(package.dir, _importsTestPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      _importsTestSource(
        package.name,
        _libraryPaths(libDir),
        _testFrameworkImport(package),
      ),
    );
}

/// The lib/-relative, sorted paths of every library in [libDir].
List<String> _libraryPaths(Directory libDir) =>
    libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(_isLibrary)
        .map((file) => _libRelativePath(file, libDir))
        .toList()
      ..sort();

final _partOf = RegExp(r'^\s*part\s+of\b', multiLine: true);

/// Whether [file] is a Dart library, not a part of one.
bool _isLibrary(File file) =>
    file.path.endsWith('.dart') && !_partOf.hasMatch(file.readAsStringSync());

String _libRelativePath(File file, Directory libDir) =>
    p.posix.joinAll(p.split(p.relative(file.path, from: libDir.path)));

String _testFrameworkImport(_Package package) => package.isFlutter
    ? 'package:flutter_test/flutter_test.dart'
    : 'package:test/test.dart';

String _importsTestSource(
  String packageName,
  List<String> libraryPaths,
  String testFrameworkImport,
) => [
  '// Written by tool/coverage.dart for a coverage run, and deleted after.',
  '// ignore_for_file: unused_import, directives_ordering',
  "import '$testFrameworkImport';",
  for (final (i, library) in libraryPaths.indexed)
    "import 'package:$packageName/$library' as _i$i;",
  '',
  "void main() => test('loads every library', () {});",
  '',
].join('\n');

// Exclusions.

/// Leaves the files matching [exclude] out of the lcov report.
Future<void> _removeExcluded(List<String> exclude) async {
  if (exclude.isEmpty) return;
  await _run('lcov', [
    '--remove', _lcovPath, ...exclude, '--output-file', _lcovPath,
    // An exclusion that matches nothing in this package isn't an error.
    '--ignore-errors', 'unused,empty',
  ]);
}

// Measuring and reporting.

/// The line counts the lcov report at [lcov] sums to.
_LineCounts _lineCounts(File lcov) {
  final lines = _readLcov(lcov);
  return _LineCounts(
    found: _sumRecords(lines, 'LF:'),
    hit: _sumRecords(lines, 'LH:'),
  );
}

List<String> _readLcov(File lcov) {
  if (!lcov.existsSync()) _fail('No coverage data at ${lcov.path}');
  return lcov.readAsLinesSync();
}

/// The sum of the counts on the lcov [lines] starting with [prefix].
int _sumRecords(List<String> lines, String prefix) => lines
    .where((line) => line.startsWith(prefix))
    .map((line) => int.parse(line.substring(prefix.length)))
    .fold(0, (sum, count) => sum + count);

/// Prints the package's result; whether it met [threshold].
bool _report(String packageName, _LineCounts counts, double threshold) {
  final passed = counts.percent >= threshold;
  stdout.writeln(
    '${passed ? '✅' : '❌'} $packageName: '
    '${counts.percent.toStringAsFixed(1)}% (required $threshold%)',
  );
  return passed;
}

// Processes.

Future<void> _run(String executable, List<String> args) async {
  final process = await Process.start(
    executable,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    _fail('`$executable ${args.join(' ')}` exited with $exitCode', exitCode);
  }
}

Never _fail(String message, [int exitCode = 1]) {
  stderr.writeln(message);
  exit(exitCode);
}

/// The package the script runs in: the current folder.
class _Package {
  /// The package's folder.
  final String dir;

  /// The package's name, from its pubspec.
  final String name;

  /// Whether the package depends on Flutter.
  final bool isFlutter;

  const _Package({
    required this.dir,
    required this.name,
    required this.isFlutter,
  });

  /// The package in the current folder.
  factory _Package.current() {
    final dir = Directory.current.path;
    final pubspec = _readPubspec(dir);
    return _Package(
      dir: dir,
      name: _packageName(pubspec),
      isFlutter: _dependsOnFlutter(pubspec),
    );
  }
}

/// A coverage.yaml's settings.
class _CoverageConfig {
  /// The required line coverage in percent, or `null` for the default.
  final double? threshold;

  /// lcov globs of the files to leave out.
  final List<String> exclude;

  const _CoverageConfig({required this.exclude, required this.threshold});

  /// No settings: what a missing or empty coverage.yaml gives.
  const _CoverageConfig.empty() : exclude = const [], threshold = null;
}

/// The line counts an lcov report sums to.
class _LineCounts {
  /// Lines that can be measured.
  final int found;

  /// Measured lines the tests ran.
  final int hit;

  const _LineCounts({required this.found, required this.hit});

  /// The line coverage in percent; 100 with no measurable lines, as nothing
  /// is uncovered then.
  double get percent => found == 0 ? 100 : hit / found * 100;
}
