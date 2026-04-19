import 'package:app_template/core/infrastructure/network/models/network_error.dart';

enum TransportErrorType {
  CONNECTION_TIMEOUT,
  SEND_TIMEOUT,
  RECEIVE_TIMEOUT,
  CONNECTION_ERROR,
  BAD_CERTIFICATE,
}

class TransportError extends NetworkError {
  final TransportErrorType type;

  const TransportError(this.type, {Object? cause, StackTrace? stackTrace})
    : super(cause, stackTrace);

  @override
  List<Object?> get props => [type, cause, stackTrace];
}
