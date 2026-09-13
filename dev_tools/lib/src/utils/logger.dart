import 'dart:io';

enum LogLevel { info, warning, error }

abstract class Logger {
  const Logger();

  void info(String message, {StackTrace? stackTrace}) {
    log(LogLevel.info, message);
  }

  void warn(String message, {StackTrace? stackTrace}) {
    log(LogLevel.warning, message);
  }

  void error(String message, {StackTrace? stackTrace}) {
    log(LogLevel.error, message, stackTrace: stackTrace);
  }

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
