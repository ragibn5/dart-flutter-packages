import 'dart:io';

import 'package:dev_tools/src/use_cases/coverage/run_package_tests_with_coverage.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String logFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('run_package_tests');
    logFile = '${tempDir.path}/calls.log';
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  RunPackageTestsWithCoverage buildSut({required int exitCode}) =>
      RunPackageTestsWithCoverage(
        flutterExecutable:
            _script(tempDir, exitCode: exitCode, logFile: logFile),
        dartExecutable: _script(tempDir, exitCode: exitCode, logFile: logFile),
        lcovExecutable: _script(tempDir, exitCode: exitCode, logFile: logFile),
      );

  test('should run flutter pub get then flutter test for a Flutter package',
      () async {
    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: true,
    );

    final calls = File(logFile).readAsLinesSync();
    expect(calls[0], 'pub get');
    expect(calls[1], contains('test'));
    expect(calls[1], contains('--coverage'));
  });

  test(
      'should run dart pub get, dart test, then convert lcov for a Dart '
      'package', () async {
    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: false,
    );

    final calls = File(logFile).readAsLinesSync();
    expect(calls[0], 'pub get');
    expect(calls[1], 'test --coverage=coverage');
    expect(calls[2], contains('format_coverage'));
  });

  test('should pass a custom lcov file path through to the test/convert step',
      () async {
    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: false,
      lcovFile: 'coverage/alt.info',
    );

    final calls = File(logFile).readAsLinesSync();
    expect(calls[2], contains('--out=coverage/alt.info'));
  });

  test('should throw PackageTestException when a step fails', () async {
    await expectLater(
      buildSut(exitCode: 1)(
        packagePath: tempDir.path,
        isFlutterPackage: true,
      ),
      throwsA(isA<PackageTestException>()),
    );
  });

  test('should not filter the lcov data when no .coverage_exclude exists',
      () async {
    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: true,
    );

    final calls = File(logFile).readAsLinesSync();
    expect(calls, isNot(contains(contains('--remove'))));
  });

  test(
      "should filter the lcov data using the package's .coverage_exclude "
      'patterns', () async {
    File('${tempDir.path}/.coverage_exclude').writeAsStringSync('''
# Generated files
lib/**/*.g.dart
''');

    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: true,
    );

    final calls = File(logFile).readAsLinesSync();
    final removeCall = calls.last;
    expect(removeCall, contains('--remove'));
    expect(removeCall, contains('coverage/lcov.info'));
    expect(removeCall, contains('lib/**/*.g.dart'));
    expect(removeCall, contains('--output-file'));
  });

  test('should throw PackageTestException when the exclusions filter fails',
      () async {
    File('${tempDir.path}/.coverage_exclude')
        .writeAsStringSync('lib/**/*.g.dart\n');
    final sut = RunPackageTestsWithCoverage(
      flutterExecutable: _script(tempDir, exitCode: 0, logFile: logFile),
      dartExecutable: _script(tempDir, exitCode: 0, logFile: logFile),
      lcovExecutable: _script(tempDir, exitCode: 1, logFile: logFile),
    );

    await expectLater(
      sut(packagePath: tempDir.path, isFlutterPackage: true),
      throwsA(isA<PackageTestException>()),
    );
  });
}

String _script(Directory dir,
    {required int exitCode, required String logFile}) {
  final script = File(
      '${dir.path}/${exitCode}_${DateTime.now().microsecondsSinceEpoch}.sh')
    ..writeAsStringSync('''
#!/bin/sh
printf "%s\\n" "\$*" >> "$logFile"
exit $exitCode
''');
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}
