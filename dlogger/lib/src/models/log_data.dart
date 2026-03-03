import 'package:dlogger/src/constants/log_level.dart';

/// A class representing a log.
class LogData {
  /// {@template field_tag}
  /// The tag of the log message.
  /// {@endtemplate}
  final String tag;

  /// {@template field_level}
  /// The level of the log message.
  /// {@endtemplate}
  final LogLevel level;

  /// {@template field_stamp}
  /// The timestamp of the log message.
  /// {@endtemplate}
  final DateTime stamp;

  /// {@template field_message}
  /// The message of the log message.
  /// {@endtemplate}
  final String message;

  /// {@template field_error}
  /// The error of the log message.
  /// {@endtemplate}
  final Object? error;

  /// {@template field_stack_trace}
  /// The stack trace of the log message.
  /// {@endtemplate}
  final StackTrace? stackTrace;

  /// {@template field_extras}
  /// The extras of the log message.
  /// {@endtemplate}
  final Map<String, dynamic>? extras;

  /// Creates a new instance of type [LogData].
  /// - [tag]:
  ///   {@macro field_tag}
  /// - [level]:
  ///   {@macro field_level}
  /// - [stamp]:
  ///   {@macro field_stamp}
  /// - [message]:
  ///   {@macro field_message}
  /// - [error]:
  ///   {@macro field_error}
  /// - [stackTrace]:
  ///   {@macro field_stack_trace}
  /// - [extras]:

  const LogData({
    required this.tag,
    required this.level,
    required this.stamp,
    required this.message,
    this.error,
    this.stackTrace,
    this.extras,
  });
}
