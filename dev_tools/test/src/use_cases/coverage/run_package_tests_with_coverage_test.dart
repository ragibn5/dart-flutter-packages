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
    // Test assets are kept: Material widgets need their shaders.
    expect(calls[1], 'test --coverage --coverage-path coverage/lcov.info');
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

  test(
      'should not filter the lcov data when no '
      'dev_tools_coverage_config.yaml exists', () async {
    await buildSut(exitCode: 0)(
      packagePath: tempDir.path,
      isFlutterPackage: true,
    );

    final calls = File(logFile).readAsLinesSync();
    expect(calls, isNot(contains(contains('--remove'))));
  });

  test(
      "should filter the lcov data using the package's "
      'dev_tools_coverage_config.yaml exclude patterns', () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml').writeAsStringSync('''
exclude:
  - lib/**/*.g.dart
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
    expect(removeCall, contains('--ignore-errors unused,empty'));
  });

  test('should throw PackageTestException when the exclusions filter fails',
      () async {
    File('${tempDir.path}/dev_tools_coverage_config.yaml')
        .writeAsStringSync('exclude:\n  - lib/**/*.g.dart\n');
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

  /// A package named `pkg` with two libraries and a part file.
  void writePackage() {
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: pkg\n');
    File('${tempDir.path}/lib/a.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync("part 'src/a.g.dart';\n");
    File('${tempDir.path}/lib/src/b.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('class B {}\n');
    File('${tempDir.path}/lib/src/a.g.dart').writeAsStringSync(
      "part of '../a.dart';\n",
    );
  }

  /// A test executable that copies the imports test into [copyFile] while
  /// it runs, and exits with [exitCode].
  String copyingScript({required int exitCode, required String copyFile}) {
    final script = File('${tempDir.path}/copying_$exitCode.sh')
      ..writeAsStringSync('''
#!/bin/sh
cp ${RunPackageTestsWithCoverage.importsTestPath} "$copyFile" 2>/dev/null
exit $exitCode
''');
    Process.runSync('chmod', ['+x', script.path]);
    return script.path;
  }

  test('callShouldImportEveryLibraryButPartsIfThePackageHasALib', () async {
    writePackage();
    final copyFile = '${tempDir.path}/copied_imports_test.dart';
    final script = copyingScript(exitCode: 0, copyFile: copyFile);

    await RunPackageTestsWithCoverage(
      flutterExecutable: script,
      dartExecutable: script,
      lcovExecutable: script,
    )(packagePath: tempDir.path, isFlutterPackage: false);

    final imports = File(copyFile).readAsStringSync();
    expect(imports, contains("import 'package:test/test.dart';"));
    expect(imports, contains("import 'package:pkg/a.dart' as _i0;"));
    expect(imports, contains("import 'package:pkg/src/b.dart' as _i1;"));
    expect(imports, isNot(contains('a.g.dart')));
    expect(
      File(
        '${tempDir.path}/${RunPackageTestsWithCoverage.importsTestPath}',
      ).existsSync(),
      isFalse,
    );
  });

  test('callShouldImportFlutterTestIfItIsAFlutterPackage', () async {
    writePackage();
    final copyFile = '${tempDir.path}/copied_imports_test.dart';
    final script = copyingScript(exitCode: 0, copyFile: copyFile);

    await RunPackageTestsWithCoverage(
      flutterExecutable: script,
      dartExecutable: script,
      lcovExecutable: script,
    )(packagePath: tempDir.path, isFlutterPackage: true);

    expect(
      File(copyFile).readAsStringSync(),
      contains("import 'package:flutter_test/flutter_test.dart';"),
    );
  });

  test('callShouldRemoveTheImportsTestIfTheTestsFail', () async {
    writePackage();
    final script = copyingScript(
      exitCode: 1,
      copyFile: '${tempDir.path}/copied_imports_test.dart',
    );

    await expectLater(
      RunPackageTestsWithCoverage(
        flutterExecutable: script,
        dartExecutable: script,
        lcovExecutable: script,
      )(packagePath: tempDir.path, isFlutterPackage: false),
      throwsA(isA<PackageTestException>()),
    );
    expect(
      File(
        '${tempDir.path}/${RunPackageTestsWithCoverage.importsTestPath}',
      ).existsSync(),
      isFalse,
    );
  });

  test('callShouldWriteNoImportsTestIfThePubspecHasNoName', () async {
    writePackage();
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync('version: 1.0.0\n');
    final copyFile = '${tempDir.path}/copied_imports_test.dart';
    final script = copyingScript(exitCode: 0, copyFile: copyFile);

    await RunPackageTestsWithCoverage(
      flutterExecutable: script,
      dartExecutable: script,
      lcovExecutable: script,
    )(packagePath: tempDir.path, isFlutterPackage: false);

    expect(File(copyFile).existsSync(), isFalse);
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
