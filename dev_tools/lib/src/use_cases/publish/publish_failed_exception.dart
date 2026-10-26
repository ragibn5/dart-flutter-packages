import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class PublishFailedException extends CommandExecutionException {
  @override
  final String message;

  const PublishFailedException(this.message);
}
