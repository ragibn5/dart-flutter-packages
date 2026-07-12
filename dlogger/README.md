# dlogger

A simple and extensible logging solution for dart and flutter apps with handy pre-built loggers.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  dlogger: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  dlogger:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dlogger
      ref: main
```

## Get started

### 1. Use the built-in loggers

If you do not need a custom implementations yet, start with the built-ins:

- `ConsoleLogger` prints logs to the console.
- `FileLogger` appends logs to a file.

#### ConsoleLogger

`ConsoleLogger` prints logs to the console.

```dart
void main() {
  final logger = ConsoleLogger();

  logger.log(
    LogData(
      tag: 'AuthService',
      level: LogLevel.INFO,
      stamp: DateTime.now(),
      message: 'Signed in successfully',
    ),
  );
}
```

#### FileLogger

`FileLogger` appends logs to a file.

```dart
import 'dart:io';

void main() {
  final logger = FileLogger(
    logDirectory: Directory('path/to/logs/dir'),
    fileNameBuilder: (_) => 'file_log.log',
  );

  logger.log(
    LogData(
      tag: 'SyncService',
      level: LogLevel.INFO,
      stamp: DateTime.now(),
      message: 'Background sync completed',
    ),
  );

  // Dispose the file logger when you are done with it.
  logger.dispose();
}
```

Use `dispose()` when you are done with a `FileLogger`, since it manages an internal stream.

#### Tips

Both of these contain an optional param called `LogFormatter` that controls how the log data is
formatted before being printed or written to a file. If not provided, it uses a default formatter
which you can obtain via `DefaultLogFormatter()`.

### 2. Create a custom logger implementation

To create a custom logger, implement the `Logger` interface.

```dart
import 'package:dlogger/dlogger.dart';

class CustomLogger implements Logger {
  @override
  void log(LogData data) {
    print('${data.level.name}: ${data.message}');
  }
}
```

### 3. Create a composite logger (`CompositeLogger`)

`CompositeLogger` forwards the same `LogData` to multiple loggers. Each child logger is registered
with a unique string ID.

```dart

final logger = CompositeLogger(
  {
    'console': ConsoleLogger(),
    'file': FileLogger(
      logDirectory: Directory('path/to/logs/dir'),
      fileNameBuilder: (_) => 'file_log.log',
    ),
  },
  const [],
);
```

This is useful when you want one log call to reach several outputs, such as the console, a file, and
a custom logger for tests or diagnostics.

### 4. Filter logs with a policy

Filters are applied by `CompositeLogger` before a child logger receives a log.

The built-in `PolicyBasedLogFilter` reads its rules from a `LogPolicyController`. The default
implementation, `DefaultLogPolicyController`, lets you block logs by tag, log level, logger ID etc.

```dart
void main() {
  final controller = DefaultLogPolicyController()
    ..addBlockedLoggerId('secondary')
    ..addBlockedLevel(LogLevel.WARNING);

  final logger = CompositeLogger(
    {
      'primary': ConsoleLogger(),
      'secondary': const MinimumLogger('secondary'),
    },
    [
      PolicyBasedLogFilter(controller),
    ],
  );

  logger.log(
    LogData(
      tag: 'api',
      level: LogLevel.INFO,
      stamp: DateTime.now(),
      message: 'This reaches only the primary logger',
    ),
  );

  logger.log(
    LogData(
      tag: 'api',
      level: LogLevel.WARNING,
      stamp: DateTime.now(),
      message: 'This is blocked for every logger',
    ),
  );
}
```

You may add multiple filters which are applied in the order they are provided, and can also be used
as interceptors.

### 5. What to use first

For most projects, a good progression is:

1. Start with `ConsoleLogger`.
2. Add `FileLogger` if you need persisted logs.
3. Wrap them in `CompositeLogger` when one log should go to multiple places.
4. Add `PolicyBasedLogFilter` when you need runtime control over what gets logged.
