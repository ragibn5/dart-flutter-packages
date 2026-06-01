import 'package:equatable/equatable.dart';

enum TransportErrorType {
  CONNECTION_TIMEOUT,
  SEND_TIMEOUT,
  RECEIVE_TIMEOUT,
  CONNECTION_ERROR,
  BAD_CERTIFICATE,
}

sealed class ApiError {
  const ApiError();
}

class TransportError extends ApiError with EquatableMixin {
  /// The type of the transport level error
  final TransportErrorType type;

  const TransportError({required this.type});

  @override
  List<Object?> get props => [type];
}

class CancellationError extends ApiError with EquatableMixin {
  /// An identifier of the cancellation source.
  final String source;

  /// Optional message about the cancellation.
  ///
  /// For example reason or context.
  final String? message;

  const CancellationError({required this.source, this.message});

  @override
  List<Object?> get props => [source, message];
}

class UnexpectedError extends ApiError with EquatableMixin {
  /// Cause of the error.
  final Object? cause;

  /// The full stack trace of the error source.
  final StackTrace? stackTrace;

  const UnexpectedError({required this.cause, required this.stackTrace});

  @override
  List<Object?> get props => [cause, stackTrace];
}
