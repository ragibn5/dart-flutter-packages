import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class FirebaseSetupException extends CommandExecutionException {
  @override
  final String message;

  const FirebaseSetupException(this.message);
}
