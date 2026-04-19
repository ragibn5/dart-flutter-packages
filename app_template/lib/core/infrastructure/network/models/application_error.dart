import 'package:app_template/core/infrastructure/network/models/network_error.dart';

enum ApplicationErrorType { CANCELLED, PARSE_ERROR, UNKNOWN_ERROR }

class ApplicationError extends NetworkError {
  final ApplicationErrorType type;

  const ApplicationError(this.type, {Object? cause, StackTrace? stackTrace})
    : super(cause, stackTrace);

  @override
  List<Object?> get props => [type, cause, stackTrace];
}
