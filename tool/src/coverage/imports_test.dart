import 'dart:io';

import 'package:path/path.dart' as p;

import 'package.dart';
import 'paths.dart';

final _partOf = RegExp(r'^\s*part\s+of\b', multiLine: true);

/// Writes a test that imports every library in lib/ (part files aside), so
/// the run loads them all; `null` when there's no lib/.
File? writeImportsTest(Package package) {
  final libDir = Directory(p.join(package.dir, 'lib'));
  if (!libDir.existsSync()) return null;
  return File(p.join(package.dir, importsTestPath))
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

/// Whether [file] is a Dart library, not a part of one.
bool _isLibrary(File file) =>
    file.path.endsWith('.dart') && !_partOf.hasMatch(file.readAsStringSync());

String _libRelativePath(File file, Directory libDir) =>
    p.posix.joinAll(p.split(p.relative(file.path, from: libDir.path)));

String _testFrameworkImport(Package package) => package.isFlutter
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
