import 'package:dlogger/src/constants/log_level.dart';
import 'package:dlogger/src/models/log_data.dart';
import 'package:dlogger/src/models/log_policy.dart';
import 'package:dlogger/src/services/log_policy_controller.dart';
import 'package:dlogger/src/services/policy_based_log_filter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogPolicyController extends Mock implements LogPolicyController {}

void main() {
  late _MockLogPolicyController mockController;

  late PolicyBasedLogFilter sut;

  setUp(() {
    mockController = _MockLogPolicyController();

    sut = PolicyBasedLogFilter(mockController);
  });

  test('blocks log based on tag', () {
    final policy = LogPolicy(
      blockedTags: {'TAG1'},
      blockedLevels: {},
      blockedLoggerIds: {},
    );
    when(() => mockController.currentPolicy).thenReturn(policy);

    final log = LogData(
      tag: 'TAG1',
      level: LogLevel.DEBUG,
      message: 'test',
      stamp: DateTime.now(),
    );

    expect(sut.shouldBlock(log, loggerId: 'any'), isTrue);
  });

  test('blocks log based on level', () {
    final policy = LogPolicy(
      blockedTags: {},
      blockedLevels: {LogLevel.ERROR},
      blockedLoggerIds: {},
    );
    when(() => mockController.currentPolicy).thenReturn(policy);

    final log = LogData(
      tag: 'TAG2',
      level: LogLevel.ERROR,
      message: 'test',
      stamp: DateTime.now(),
    );

    expect(sut.shouldBlock(log, loggerId: 'any'), isTrue);
  });

  test('blocks log based on loggerId', () {
    final policy = LogPolicy(
      blockedTags: {},
      blockedLevels: {},
      blockedLoggerIds: {'logger-1'},
    );
    when(() => mockController.currentPolicy).thenReturn(policy);

    final log = LogData(
      tag: 'TAG2',
      level: LogLevel.DEBUG,
      message: 'test',
      stamp: DateTime.now(),
    );

    expect(sut.shouldBlock(log, loggerId: 'logger-1'), isTrue);
  });

  test('does not block log if nothing matches', () {
    final policy = LogPolicy(
      blockedTags: {'TAG1'},
      blockedLevels: {LogLevel.ERROR},
      blockedLoggerIds: {'logger-1'},
    );
    when(() => mockController.currentPolicy).thenReturn(policy);

    final log = LogData(
      tag: 'TAG2',
      level: LogLevel.DEBUG,
      message: 'test',
      stamp: DateTime.now(),
    );

    expect(sut.shouldBlock(log, loggerId: 'logger-2'), isFalse);
  });
}
