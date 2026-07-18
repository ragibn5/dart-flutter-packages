import 'package:loghub/src/models/log_data.dart';
import 'package:loghub/src/models/log_policy.dart';
import 'package:loghub/src/services/log_filter.dart';
import 'package:loghub/src/services/log_policy_controller.dart';

/// A [LogFilter] implementation that blocks logs based on a [LogPolicy].
final class PolicyBasedLogFilter implements LogFilter {
  /// {@template field_controller}
  /// A [LogPolicyController] instance holding the current policy ([LogPolicy]).
  /// {@endtemplate}
  final LogPolicyController _controller;

  /// Creates a new instance of type [PolicyBasedLogFilter].
  /// - [controller]:
  ///   {@macro field_controller}
  PolicyBasedLogFilter(LogPolicyController controller)
      : _controller = controller;

  @override
  bool shouldBlock(LogData logData, {required String loggerId}) {
    final policy = _controller.currentPolicy;
    return policy.blockedTags.contains(logData.tag) ||
        policy.blockedLevels.contains(logData.level) ||
        policy.blockedLoggerIds.contains(loggerId);
  }
}
