import 'package:dlogger/src/constants/log_level.dart';
import 'package:dlogger/src/services/default_log_policy_controller.dart';
import 'package:test/test.dart';

void main() {
  late DefaultLogPolicyController sut;

  setUp(() {
    sut = DefaultLogPolicyController();
  });

  test('initial state is empty', () {
    expect(sut.currentPolicy.blockedTags, isEmpty);
    expect(sut.currentPolicy.blockedLevels, isEmpty);
    expect(sut.currentPolicy.blockedLoggerIds, isEmpty);
  });

  test('adds and removes blocked tags', () {
    sut.addBlockedTag('tag1');
    expect(sut.currentPolicy.blockedTags, contains('tag1'));

    sut.removeBlockedTag('tag1');
    expect(sut.currentPolicy.blockedTags, isNot(contains('tag1')));
  });

  test('adds and removes blocked levels', () {
    sut.addBlockedLevel(LogLevel.ERROR);
    expect(sut.currentPolicy.blockedLevels, contains(LogLevel.ERROR));

    sut.removeBlockedLevel(LogLevel.ERROR);
    expect(sut.currentPolicy.blockedLevels, isNot(contains(LogLevel.ERROR)));
  });

  test('adds and removes blocked logger ids', () {
    sut.addBlockedLoggerId('logger-1');
    expect(sut.currentPolicy.blockedLoggerIds, contains('logger-1'));

    sut.removeBlockedLoggerId('logger-1');
    expect(sut.currentPolicy.blockedLoggerIds, isNot(contains('logger-1')));
  });

  test('adding duplicates and removing non-existent items does not throw', () {
    sut
      ..addBlockedTag('tag1')
      ..addBlockedTag('tag1'); // duplicate
    expect(sut.currentPolicy.blockedTags.length, 1);

    sut
      ..removeBlockedTag('nonexistent') // should not throw
      ..addBlockedLevel(LogLevel.ERROR)
      ..addBlockedLevel(LogLevel.ERROR); // duplicate
    expect(sut.currentPolicy.blockedLevels.length, 1);

    sut
      ..removeBlockedLevel(LogLevel.DEBUG) // should not throw
      ..addBlockedLoggerId('logger-1')
      ..addBlockedLoggerId('logger-1'); // duplicate
    expect(sut.currentPolicy.blockedLoggerIds.length, 1);

    sut.removeBlockedLoggerId('logger-2'); // should not throw
  });

  test('test constructor initializes with provided sets', () {
    final tags = {'t1', 't2'};
    final levels = {LogLevel.DEBUG, LogLevel.INFO};
    final ids = {'logger1', 'logger2'};

    final testController = DefaultLogPolicyController.test(tags, levels, ids);

    expect(testController.currentPolicy.blockedTags, equals(tags));
    expect(testController.currentPolicy.blockedLevels, equals(levels));
    expect(testController.currentPolicy.blockedLoggerIds, equals(ids));
  });
}
