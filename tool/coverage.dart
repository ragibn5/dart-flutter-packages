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

Future<void> main(List<String> args) async {
  final packageDir = Directory.current.path;
  final repoRoot = p.dirname(p.dirname(Platform.script.toFilePath()));

  final pubspec =
      loadYaml(File(p.join(packageDir, 'pubspec.yaml')).readAsStringSync())
          as YamlMap;
  final name = pubspec['name'] as String;
  final isFlutter = (pubspec['dependencies'] as YamlMap?)?['flutter'] != null;

  final packageConfig = _readConfig(p.join(packageDir, _configFileName));
  final repoConfig = _readConfig(p.join(repoRoot, _configFileName));
  final threshold = packageConfig.threshold ?? _thresholdArg(args) ?? 100;
  final exclude = [...repoConfig.exclude, ...packageConfig.exclude];

  final importsTest = _writeImportsTest(packageDir, name, isFlutter: isFlutter);
  try {
    if (isFlutter) {
      await _run('flutter', [
        'test',
        '--coverage',
        '--coverage-path',
        _lcovPath,
      ]);
    } else {
      await _run('dart', ['test', '--coverage=coverage']);
      await _run('dart', [
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
    }
  } finally {
    if (importsTest != null && importsTest.existsSync()) {
      importsTest.deleteSync();
    }
  }

  if (exclude.isNotEmpty) {
    await _run('lcov', [
      '--remove', _lcovPath, ...exclude, '--output-file', _lcovPath,
      // An exclusion that matches nothing in this package isn't an error.
      '--ignore-errors', 'unused,empty',
    ]);
  }

  final coverage = _lineCoverage(File(p.join(packageDir, _lcovPath)));
  final passed = coverage >= threshold;
  stdout.writeln(
    '${passed ? '✅' : '❌'} $name: ${coverage.toStringAsFixed(1)}% '
    '(required $threshold%)',
  );
  if (!passed) exit(1);
}

typedef _Config = ({List<String> exclude, double? threshold});

_Config _readConfig(String path) {
  final file = File(path);
  if (!file.existsSync()) return (exclude: const [], threshold: null);
  final doc = loadYaml(file.readAsStringSync());
  if (doc is! YamlMap) return (exclude: const [], threshold: null);
  final exclude = doc['exclude'];
  final threshold = doc['threshold'];
  return (
    exclude: exclude is YamlList ? exclude.map((e) => '$e').toList() : const [],
    threshold: threshold is num ? threshold.toDouble() : null,
  );
}

double? _thresholdArg(List<String> args) {
  final i = args.indexOf('--threshold');
  return i >= 0 && i + 1 < args.length ? double.tryParse(args[i + 1]) : null;
}

/// Writes a test that imports every library in lib/ (part files aside), so
/// the run loads them all; `null` when there's no lib/.
File? _writeImportsTest(
  String packageDir,
  String name, {
  required bool isFlutter,
}) {
  final libDir = Directory(p.join(packageDir, 'lib'));
  if (!libDir.existsSync()) return null;

  final partOf = RegExp(r'^\s*part\s+of\b', multiLine: true);
  final libraries =
      libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !partOf.hasMatch(f.readAsStringSync()))
          .map(
            (f) =>
                p.posix.joinAll(p.split(p.relative(f.path, from: libDir.path))),
          )
          .toList()
        ..sort();

  final testImport = isFlutter
      ? 'package:flutter_test/flutter_test.dart'
      : 'package:test/test.dart';
  return File(p.join(packageDir, _importsTestPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      [
        '// Written by tool/coverage.dart for a coverage run, and deleted after.',
        '// ignore_for_file: unused_import, directives_ordering',
        "import '$testImport';",
        for (final (i, library) in libraries.indexed)
          "import 'package:$name/$library' as _i$i;",
        '',
        "void main() => test('loads every library', () {});",
        '',
      ].join('\n'),
    );
}

/// The line coverage in [lcov], in percent; 100 when it holds no measurable
/// lines, as nothing is uncovered then.
double _lineCoverage(File lcov) {
  if (!lcov.existsSync()) {
    stderr.writeln('No coverage data at ${lcov.path}');
    exit(1);
  }
  var found = 0;
  var hit = 0;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
  }
  return found == 0 ? 100 : hit / found * 100;
}

Future<void> _run(String executable, List<String> args) async {
  final process = await Process.start(
    executable,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    stderr.writeln('`$executable ${args.join(' ')}` exited with $exitCode');
    exit(exitCode);
  }
}
