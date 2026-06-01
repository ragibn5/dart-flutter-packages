// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/shared/logger/app_log_policy_controller_impl.dart';
import 'package:app_template/shared/logger/app_logger_id.dart';
import 'package:dlogger/dlogger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogPolicyController extends Mock implements LogPolicyController {}

void main() {
  late _MockLogPolicyController mockController;

  late AppLogPolicyControllerImpl appController;

  setUp(() {
    mockController = _MockLogPolicyController();

    appController = AppLogPolicyControllerImpl(mockController);
  });

  test('blockLevel delegates to library controller', () {
    appController.blockLevel(.INFO);

    verify(() => mockController.addBlockedLevel(LogLevel.INFO)).called(1);
  });

  test('unblockLevel delegates to library controller', () {
    appController.unblockLevel(.ERROR);

    verify(() => mockController.removeBlockedLevel(LogLevel.ERROR)).called(1);
  });

  test('blockLogger delegates to library controller', () {
    const loggerId = AppLoggerId.CONSOLE;
    appController.blockLogger(loggerId);
    verify(() => mockController.addBlockedLoggerId(loggerId.name)).called(1);
  });

  test('unblockLogger delegates to library controller', () {
    const loggerId = AppLoggerId.FILE;
    appController.unblockLogger(loggerId);
    verify(() => mockController.removeBlockedLoggerId(loggerId.name)).called(1);
  });

  test('blockTag delegates to library controller', () {
    const tag = 'NETWORK';
    appController.blockTag(tag);
    verify(() => mockController.addBlockedTag(tag)).called(1);
  });

  test('unblockTag delegates to library controller', () {
    const tag = 'UI';
    appController.unblockTag(tag);
    verify(() => mockController.removeBlockedTag(tag)).called(1);
  });
}
