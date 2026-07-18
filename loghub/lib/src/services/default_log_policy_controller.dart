import 'package:loghub/src/constants/log_level.dart';
import 'package:loghub/src/models/log_policy.dart';
import 'package:loghub/src/services/log_policy_controller.dart';
import 'package:meta/meta.dart';

/// Default implementation of [LogPolicyController].
class DefaultLogPolicyController implements LogPolicyController {
  final Set<String> _blockedTags;
  final Set<LogLevel> _blockedLevels;
  final Set<String> _blockedLoggerIds;

  /// Creates a new instance of type [DefaultLogPolicyController].
  DefaultLogPolicyController() : this._({}, {}, {});

  @visibleForTesting
  DefaultLogPolicyController.test(Set<String> blockedTags,
      Set<LogLevel> blockedLevels, Set<String> blockedLoggerIds)
      : _blockedTags = blockedTags,
        _blockedLevels = blockedLevels,
        _blockedLoggerIds = blockedLoggerIds;

  DefaultLogPolicyController._(Set<String> blockedTags,
      Set<LogLevel> blockedLevels, Set<String> blockedLoggerIds)
      : _blockedTags = blockedTags,
        _blockedLevels = blockedLevels,
        _blockedLoggerIds = blockedLoggerIds;

  @override
  LogPolicy get currentPolicy => LogPolicy(
        blockedTags: _blockedTags,
        blockedLevels: _blockedLevels,
        blockedLoggerIds: _blockedLoggerIds,
      );

  @override
  void addBlockedTag(String tag) => _blockedTags.add(tag);

  @override
  void removeBlockedTag(String tag) => _blockedTags.remove(tag);

  @override
  void addBlockedLevel(LogLevel level) => _blockedLevels.add(level);

  @override
  void removeBlockedLevel(LogLevel level) => _blockedLevels.remove(level);

  @override
  void addBlockedLoggerId(String loggerId) => _blockedLoggerIds.add(loggerId);

  @override
  void removeBlockedLoggerId(String loggerId) =>
      _blockedLoggerIds.remove(loggerId);
}
