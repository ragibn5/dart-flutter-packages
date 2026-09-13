import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class CoverageThresholdException extends CommandExecutionException {
  @override
  final String message;

  const CoverageThresholdException(this.message);
}
