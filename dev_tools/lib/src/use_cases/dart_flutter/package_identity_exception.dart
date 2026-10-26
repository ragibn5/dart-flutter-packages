import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

/// Represents an exception related to a package's malformed identity.
class PackageIdentityException extends CommandExecutionException {
  @override
  final String message;

  const PackageIdentityException(this.message);
}
