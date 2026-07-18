import 'package:loghub/src/constants/log_level.dart';
import 'package:loghub/src/models/log_policy.dart';
import 'package:loghub/src/services/default_log_policy_controller.dart';

/// A controller to control the log policy.
///
/// If you do not want to create an implementation, you may
/// use [DefaultLogPolicyController], which handles everything
/// for you.
abstract interface class LogPolicyController {
  /// The current log policy.
  LogPolicy get currentPolicy;

  /// Adds a blocked tag.
  /// - [tag]: The tag to add.
  void addBlockedTag(String tag);

  /// Removes a blocked tag.
  /// - [tag]: The tag to remove.
  void removeBlockedTag(String tag);

  /// Adds a blocked level.
  /// - [level]: The level to add.
  void addBlockedLevel(LogLevel level);

  /// Removes a blocked level.
  /// - [level]: The level to remove.
  void removeBlockedLevel(LogLevel level);

  /// Adds a blocked logger id.
  /// - [loggerId]: The logger id to add.
  void addBlockedLoggerId(String loggerId);

  /// Removes a blocked logger id.
  /// - [loggerId]: The logger id to remove.
  void removeBlockedLoggerId(String loggerId);
}
