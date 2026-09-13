// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/exceptions/coverage_threshold_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_threshold.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

class _FakeLogger extends Logger {
  final List<String> messages = [];

  @override
  void log(LogLevel level, String message, {StackTrace? stackTrace}) =>
      messages.add(message);
}

void main() {
  const root = '/fake/root';

  late _MockCalculateCoverage coverageUtils;
  late _FakeLogger logger;

  late EnforceCoverageThreshold sut;

  setUp(() {
    coverageUtils = _MockCalculateCoverage();
    logger = _FakeLogger();

    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 100);

    sut =
        EnforceCoverageThreshold(coverageUtils: coverageUtils, logger: logger);
  });

  test('should not throw when coverage meets the threshold', () async {
    await expectLater(sut(projectRoot: root), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 95);

    await expectLater(sut(projectRoot: root, threshold: 90), completes);
  });

  test('should forward the lcov file and project root to CalculateCoverage',
      () async {
    await sut(projectRoot: root, lcovFile: 'coverage/alt.info');

    verify(() => coverageUtils('coverage/alt.info', root)).called(1);
  });

  test('should write coverage message to stdout on success', () async {
    await sut(projectRoot: root);

    expect(logger.messages, contains(contains('Coverage meets required 100%')));
  });

  test(
    'should throw CoverageThresholdException when coverage is below threshold',
    () async {
      when(() => coverageUtils(any(), any())).thenAnswer((_) async => 80);

      await expectLater(
        sut(projectRoot: root),
        throwsA(isA<CoverageThresholdException>()),
      );
    },
  );

  test('should accept a fractional threshold on success', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 90);

    await expectLater(sut(projectRoot: root, threshold: 88.5), completes);

    expect(
      logger.messages,
      contains(contains('Coverage meets required 88.5%.')),
    );
  });

  test('should include the fractional threshold in the exception message',
      () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 50);

    await expectLater(
      sut(projectRoot: root, threshold: 80.5),
      throwsA(
        allOf(
          isA<CoverageThresholdException>(),
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
