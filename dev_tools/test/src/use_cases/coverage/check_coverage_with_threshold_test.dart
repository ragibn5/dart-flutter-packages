// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/check_coverage_with_threshold.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

class _FakeLogger implements Logger {
  final List<String> messages = [];

  @override
  void info(String message) => messages.add(message);

  @override
  void warn(String message) => messages.add(message);

  @override
  void error(String message, {StackTrace? stackTrace}) => messages.add(message);
}

void main() {
  const root = '/fake/root';

  late _MockFindProjectRoot findProjectRoot;
  late _MockCalculateCoverage coverageUtils;
  late _FakeLogger logger;

  late EnforceCoverageThreshold sut;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    coverageUtils = _MockCalculateCoverage();
    logger = _FakeLogger();

    when(() => findProjectRoot()).thenAnswer((_) async => root);
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 100);

    sut = EnforceCoverageThreshold(
      findProjectRoot: findProjectRoot,
      coverageUtils: coverageUtils,
      logger: logger,
    );
  });

  test('should not throw when coverage meets the threshold', () async {
    await expectLater(sut(), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 95);

    await expectLater(sut(threshold: 90), completes);
  });

  test('should write coverage message to stdout on success', () async {
    await sut();

    expect(logger.messages, contains(contains('Coverage meets required 100%')));
  });

  test(
    'should throw EnforceCoverageThresholdException when coverage is below threshold',
    () async {
      when(() => coverageUtils(any(), any())).thenAnswer((_) async => 80);

      await expectLater(
        sut(),
        throwsA(isA<EnforceCoverageThresholdException>()),
      );
    },
  );

  test('should accept a fractional threshold on success', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 90);

    await expectLater(sut(threshold: 88.5), completes);

    expect(
      logger.messages,
      contains(contains('Coverage meets required 88.5%.')),
    );
  });

  test('should include the fractional threshold in the exception message',
      () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 50);

    await expectLater(
      sut(threshold: 80.5),
      throwsA(
        allOf(
          isA<EnforceCoverageThresholdException>(),
          predicate(
            (exception) =>
                exception.toString().contains('50%') &&
                exception.toString().contains('80.5%'),
            'exception message includes coverage and threshold',
          ),
        ),
      ),
    );
  });
}
