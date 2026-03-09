import 'package:dlogger/src/constants/log_level.dart';
import 'package:dlogger/src/services/default_log_policy_controller.dart';
import 'package:test/test.dart';

void main() {
  late DefaultLogPolicyController controller;

  setUp(() {
    controller = DefaultLogPolicyController();
  });

  test('initial state is empty', () {
    expect(controller.currentPolicy.blockedTags, isEmpty);
    expect(controller.currentPolicy.blockedLevels, isEmpty);
    expect(controller.currentPolicy.blockedLoggerIds, isEmpty);
  });

  test('adds and removes blocked tags', () {
    controller.addBlockedTag('tag1');
    expect(controller.currentPolicy.blockedTags, contains('tag1'));

    controller.removeBlockedTag('tag1');
    expect(controller.currentPolicy.blockedTags, isNot(contains('tag1')));
  });

  test('adds and removes blocked levels', () {
    controller.addBlockedLevel(LogLevel.ERROR);
    expect(controller.currentPolicy.blockedLevels, contains(LogLevel.ERROR));

    controller.removeBlockedLevel(LogLevel.ERROR);
    expect(controller.currentPolicy.blockedLevels,
        isNot(contains(LogLevel.ERROR)));
  });

  test('adds and removes blocked logger ids', () {
    controller.addBlockedLoggerId('logger-1');
    expect(controller.currentPolicy.blockedLoggerIds, contains('logger-1'));

    controller.removeBlockedLoggerId('logger-1');
    expect(
        controller.currentPolicy.blockedLoggerIds, isNot(contains('logger-1')));
  });

  test('adding duplicates and removing non-existent items does not throw', () {
    controller
      ..addBlockedTag('tag1')
      ..addBlockedTag('tag1'); // duplicate
    expect(controller.currentPolicy.blockedTags.length, 1);

    controller
      ..removeBlockedTag('nonexistent') // should not throw
      ..addBlockedLevel(LogLevel.ERROR)
      ..addBlockedLevel(LogLevel.ERROR); // duplicate
    expect(controller.currentPolicy.blockedLevels.length, 1);

    controller
      ..removeBlockedLevel(LogLevel.DEBUG) // should not throw
      ..addBlockedLoggerId('logger-1')
      ..addBlockedLoggerId('logger-1'); // duplicate
    expect(controller.currentPolicy.blockedLoggerIds.length, 1);

    controller.removeBlockedLoggerId('logger-2'); // should not throw
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
