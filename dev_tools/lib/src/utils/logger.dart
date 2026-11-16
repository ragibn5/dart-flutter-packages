import 'dart:io';

import 'package:meta/meta.dart';

/// Severity of a single log message.
enum LogLevel { info, warning, error }

/// Reports progress/diagnostic messages, decoupled from where they actually
/// end up (console, captured buffer, etc.).
abstract class Logger {
  const Logger();

  void info(String message, {StackTrace? stackTrace}) =>
      log(LogLevel.info, message, stackTrace: stackTrace);

  void warn(String message, {StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, stackTrace: stackTrace);

  void error(String message, {StackTrace? stackTrace}) =>
      log(LogLevel.error, message, stackTrace: stackTrace);

  /// Writes [message] at [level]. Subclasses implement only this method;
  /// [info]/[warn]/[error] are convenience wrappers around it.
  @visibleForOverriding
  void log(LogLevel level, String message, {StackTrace? stackTrace});

  Future<T> withGroupedLog<T>(
    String title,
    Future<T> Function(Logger logger) body,
  ) async {
    info('::group::$title');
    try {
      return await body(this);
    } finally {
      info('::endgroup::');
    }
  }
}

class ConsoleLogger extends Logger {
  const ConsoleLogger();

  @override
  void log(LogLevel level, String message, {StackTrace? stackTrace}) {
    final out = stdout;
    final err = stderr;
    switch (level) {
      case LogLevel.info:
        out.writeln(_buildMessage(message, stackTrace: stackTrace));
        break;
      case LogLevel.warning:
        err.writeln(_buildMessage(message, stackTrace: stackTrace));
        break;
      case LogLevel.error:
        err.writeln(_buildMessage(message, stackTrace: stackTrace));
    }
  }

  String _buildMessage(String message, {StackTrace? stackTrace}) {
    final sb = StringBuffer(message);
    if (stackTrace != null) {
      sb
        ..writeln()
        ..writeln(stackTrace.toString());
    }
    return sb.toString();
  }
}
