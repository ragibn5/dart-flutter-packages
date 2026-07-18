import 'dart:io';

import 'package:loghub/loghub.dart';

void main() async {
  // Using temporary to demonstrate only.
  final logDir = Directory.systemTemp.createTempSync('dlogger_example_');

  // 1. ConsoleLogger — prints formatted logs to stdout.
  final consoleLogger = ConsoleLogger()
    ..log(
      LogData(
        tag: 'App',
        level: LogLevel.INFO,
        stamp: DateTime.now(),
        message: 'Hello from ConsoleLogger!',
      ),
    );

  // 2. FileLogger — appends formatted logs to a file.
  final fileLogger = FileLogger(
    logDirectory: logDir,
    fileNameBuilder: (_) => 'app.log',
  )..log(
      LogData(
        tag: 'App',
        level: LogLevel.WARNING,
        stamp: DateTime.now(),
        message: 'Something looks off.',
      ),
    );

  // 3. CompositeLogger — fan out one log call to multiple loggers.
  CompositeLogger(
    {
      'console': consoleLogger,
      'file': fileLogger,
    },
    [],
  ).log(
    LogData(
      tag: 'App',
      level: LogLevel.DEBUG,
      stamp: DateTime.now(),
      message: 'This goes to both console and file.',
    ),
  );

  // 4. Filtering — block logs below a certain level.
  final controller = DefaultLogPolicyController()
    ..addBlockedLevel(LogLevel.DEBUG);

  CompositeLogger(
    {
      'console': consoleLogger,
    },
    [
      PolicyBasedLogFilter(controller),
    ],
  )
    ..log(
      LogData(
        tag: 'App',
        level: LogLevel.DEBUG,
        stamp: DateTime.now(),
        message: 'This will NOT appear (blocked).',
      ),
    )
    ..log(
      LogData(
        tag: 'App',
        level: LogLevel.ERROR,
        stamp: DateTime.now(),
        message: 'This WILL appear.',
      ),
    );

  // Clean up.
  fileLogger.dispose();
  logDir.deleteSync(recursive: true);
}
