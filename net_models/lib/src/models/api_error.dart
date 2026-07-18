import 'package:net_models/src/enums/transport_error_type.dart';

sealed class ApiError {
  const ApiError();
}

class TransportError extends ApiError {
  final TransportErrorType type;

  const TransportError({required this.type});
}

class CancellationError extends ApiError {
  final String source;
  final String? message;

  const CancellationError({required this.source, this.message});
}

class UnexpectedError extends ApiError {
  final Object? cause;
  final StackTrace? stackTrace;

  const UnexpectedError({required this.cause, required this.stackTrace});
}
