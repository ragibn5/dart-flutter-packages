import 'dart:io';

import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ReadCoverageConfig sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('read_coverage_config');
    sut = const ReadCoverageConfig();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
      'should return an empty config when no '
      'dev_tools_coverage_config.yaml file exists', () async {
    final result = await sut(tempDir.path);

    expect(result.exclude, isEmpty);
    expect(result.threshold, isNull);
  });

  test('should read exclude patterns and threshold together', () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml').writeAsStringSync('''
threshold: 90
exclude:
  - lib/**/*.g.dart
  - lib/generated/**
''');

    final result = await sut(tempDir.path);

    expect(result.exclude, ['lib/**/*.g.dart', 'lib/generated/**']);
    expect(result.threshold, 90.0);
  });

  test('should return only exclude patterns when threshold is omitted',
      () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml').writeAsStringSync('''
exclude:
  - lib/**/*.g.dart
''');

    final result = await sut(tempDir.path);

    expect(result.exclude, ['lib/**/*.g.dart']);
    expect(result.threshold, isNull);
  });

  test('should return only a threshold override when exclude is omitted',
      () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml')
        .writeAsStringSync('threshold: 80');

    final result = await sut(tempDir.path);

    expect(result.exclude, isEmpty);
    expect(result.threshold, 80.0);
  });

  test('should return an empty config for an empty file', () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml')
        .writeAsStringSync('');

    final result = await sut(tempDir.path);

    expect(result.exclude, isEmpty);
    expect(result.threshold, isNull);
  });

  /// A repository at [tempDir], with [packagePath] inside it.
  String createRepoWithPackage(String packagePath) {
    Directory('${tempDir.path}/.git').createSync();
    return (Directory('${tempDir.path}/$packagePath')
          ..createSync(recursive: true))
        .path;
  }

  test('callShouldPutTheRepoExclusionsBeforeThePackagesIfTheRepoHasAConfig',
      () async {
    final packagePath = createRepoWithPackage('pkg');
    File('${tempDir.path}/dev_tools_coverage_config.yaml').writeAsStringSync('''
exclude:
  - '*/models/*'
''');
    File('$packagePath/dev_tools_coverage_config.yaml').writeAsStringSync('''
threshold: 90
exclude:
  - lib/generated/**
''');

    final result = await sut(packagePath);

    expect(result.exclude, ['*/models/*', 'lib/generated/**']);
    expect(result.threshold, 90.0);
  });

  test('callShouldIgnoreTheRepoThresholdIfTheRepoConfigSetsOne', () async {
    final packagePath = createRepoWithPackage('pkg');
    File('${tempDir.path}/dev_tools_coverage_config.yaml')
        .writeAsStringSync('threshold: 50');

    final result = await sut(packagePath);

    expect(result.threshold, isNull);
  });

  test('callShouldFindTheRepoRootIfThePackageIsNestedDeeper', () async {
    final packagePath = createRepoWithPackage('app/packages/pkg');
    File('${tempDir.path}/dev_tools_coverage_config.yaml').writeAsStringSync('''
exclude:
  - '*.g.dart'
''');

    final result = await sut(packagePath);

    expect(result.exclude, ['*.g.dart']);
  });
}
