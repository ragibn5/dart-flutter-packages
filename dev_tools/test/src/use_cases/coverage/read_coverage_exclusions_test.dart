import 'dart:io';

import 'package:dev_tools/src/use_cases/coverage/read_coverage_exclusions.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ReadCoverageExclusions sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('read_coverage_exclusions');
    sut = const ReadCoverageExclusions();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should return an empty list when no .coverage_exclude file exists',
      () async {
    final result = await sut(tempDir.path);

    expect(result, isEmpty);
  });

  test('should return each non-empty, non-comment line as a pattern', () async {
    File('${tempDir.path}/.coverage_exclude').writeAsStringSync('''
# Generated files
lib/**/*.g.dart
lib/**/*.freezed.dart

# DI setup
lib/di/**
''');

    final result = await sut(tempDir.path);

    expect(result, [
      'lib/**/*.g.dart',
      'lib/**/*.freezed.dart',
      'lib/di/**',
    ]);
  });

  test('should trim surrounding whitespace from each pattern', () async {
    File('${tempDir.path}/.coverage_exclude')
        .writeAsStringSync('  lib/**/*.g.dart  \n');

    final result = await sut(tempDir.path);

    expect(result, ['lib/**/*.g.dart']);
  });

  test('should return an empty list for a file with only comments/blanks',
      () async {
    File('${tempDir.path}/.coverage_exclude').writeAsStringSync('''
# nothing here

''');

    final result = await sut(tempDir.path);

    expect(result, isEmpty);
  });
}
