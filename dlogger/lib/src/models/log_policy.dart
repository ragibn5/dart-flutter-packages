import 'package:dlogger/src/constants/log_level.dart';

/// A class representing a log policy.
final class LogPolicy {
  /// {@template field_blocked_tags}
  /// A set of tags that should be blocked from logging.
  /// {@endtemplate}
  final Set<String> blockedTags;

  /// {@template field_blocked_levels}
  /// A set of log levels that should be blocked from logging.
  /// {@endtemplate}
  final Set<LogLevel> blockedLevels;

  /// {@template field_blocked_logger_ids}
  /// A set of logger IDs that should be blocked from logging.
  /// {@endtemplate}
  final Set<String> blockedLoggerIds;

  /// Creates a new instance of type [LogPolicy].
  /// - [blockedTags]:
  ///   {@macro field_blocked_tags}
  /// - [blockedLevels]:
  ///   {@macro field_blocked_levels}
  /// - [blockedLoggerIds]:
  ///   {@macro field_blocked_logger_ids}
  LogPolicy({
    required Set<String> blockedTags,
    required Set<LogLevel> blockedLevels,
    required Set<String> blockedLoggerIds,
  })  : blockedTags = Set.unmodifiable(blockedTags),
        blockedLevels = Set.unmodifiable(blockedLevels),
        blockedLoggerIds = Set.unmodifiable(blockedLoggerIds);
}
