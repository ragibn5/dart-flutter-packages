// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/process_coverage_data.dart';
import 'package:dev_tools/src/use_cases/coverage/read_coverage_config.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockCmdChecker extends Mock implements CmdInstallationChecker {}

class _MockReadCoverageConfig extends Mock implements ReadCoverageConfig {}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;

void main() {
  late Directory tempDir;
  late _MockFindProjectRoot findProjectRoot;
  late _MockCmdChecker cmdChecker;
  late _MockReadCoverageConfig readCoverageConfig;

  late ProcessCoverageDataWithLcov sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('process_coverage_data_test');
    findProjectRoot = _MockFindProjectRoot();
    cmdChecker = _MockCmdChecker();
    readCoverageConfig = _MockReadCoverageConfig();

    when(() => findProjectRoot()).thenAnswer((_) async => tempDir.path);
    when(() => readCoverageConfig(any()))
        .thenAnswer((_) async => (exclude: const <String>[], threshold: null));

    sut = ProcessCoverageDataWithLcov(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
      readCoverageConfig: readCoverageConfig,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should throw CommandNotFoundException when lcov is not installed',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => false);

      await expectLater(sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run lcov when it is installed',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      Directory('${tempDir.path}/coverage').createSync(recursive: true);
      File('${tempDir.path}/coverage/lcov.info').writeAsStringSync(
        'SF:lib/foo.dart\nDA:1,1\nend_of_record\n',
      );

      await expectLater(sut(), completes);
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );

  test(
    'should throw LcovFilteringException when lcov exits non-zero',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      // No coverage/lcov.info written, so lcov has nothing to read.

      await expectLater(sut(), throwsA(isA<LcovFilteringException>()));
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );

  test(
    "should fall back to dev_tools_coverage_config.yaml's exclude "
    'patterns when none are passed explicitly',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      Directory('${tempDir.path}/coverage').createSync(recursive: true);
      File('${tempDir.path}/coverage/lcov.info').writeAsStringSync(
        'SF:lib/foo.dart\nDA:1,1\nend_of_record\n'
        'SF:lib/bar.dart\nDA:1,1\nend_of_record\n',
      );
      when(() => readCoverageConfig(any())).thenAnswer(
        (_) async => (exclude: const ['lib/foo.dart'], threshold: null),
      );

      await sut();

      final content =
          File('${tempDir.path}/coverage/lcov.info').readAsStringSync();
      expect(content, isNot(contains('lib/foo.dart')));
      expect(content, contains('lib/bar.dart'));
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );

  test(
    'should not consult dev_tools_coverage_config.yaml when exclusions are '
    'passed explicitly',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      Directory('${tempDir.path}/coverage').createSync(recursive: true);
      File('${tempDir.path}/coverage/lcov.info').writeAsStringSync(
        'SF:lib/foo.dart\nDA:1,1\nend_of_record\n',
      );

      await sut(exclusions: ['lib/foo.dart']);

      verifyNever(() => readCoverageConfig(any()));
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );
}
