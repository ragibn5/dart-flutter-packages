import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

/// Thrown when a value required from a project's
/// `dev_tools_whitelabel_config.yaml` isn't configured. There is no default
/// that could be correct for an arbitrary project, so the caller must
/// declare it explicitly rather than have one guessed.
class WhitelabelConfigException extends CommandExecutionException {
  @override
  final String message;

  const WhitelabelConfigException(this.message);
}
